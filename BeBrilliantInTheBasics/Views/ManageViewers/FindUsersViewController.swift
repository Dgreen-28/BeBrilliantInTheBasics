//
//  FindUsersViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 3/4/24.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

class FindUsersViewController: UIViewController {
    
    private var tableView: UITableView!
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .clear
        searchBar.placeholder = "Search Users"
        searchBar.autocapitalizationType = .none // Disable autocapitalization
        return searchBar
    }()
    
    private var users: [(username: String, email: String)] = [] // Array of tuples to store username and email
    private var userStatusCache: [String: Bool] = [:] // Cache to store whether the user is already added
    private let db = Firestore.firestore() // Firestore instance
    private var currentUserID: String = "" // Current user's ID
    
    // Closure to handle button action
    var buttonAction: ((String, Bool) -> Void)?
    
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        self.title = "Search"

        // Set up the current user's ID (You need to set this up appropriately)
        currentUserID = currentUser?.uid ?? ""
        
        // Set up button action closure
        buttonAction = { [weak self] email, isAdding in
            if isAdding {
                self?.addUserByEmail(email: email)
            } else {
                self?.removeUserByEmail(email: email)
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupSearchBar() {
        // Add search bar to the view
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        // Position the search bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        // Configure table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        // Position the table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func findUsers(withUsername username: String) {
        // Clear previous user data
        users.removeAll()
        userStatusCache.removeAll() // Clear cache as well
        
        guard let currentUser = Auth.auth().currentUser else {
            print("Current user not found")
            return
        }
        
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                // Fetch the current user's username
                if let currentUsername = document.data()?["username"] as? String {
                    // Query Firestore for users with usernames containing the specified characters
                    self.db.collection("users")
                        .whereField("username", isGreaterThanOrEqualTo: username)
                        .whereField("username", isLessThanOrEqualTo: username + "\u{f8ff}") // "\u{f8ff}" is a Unicode character representing the highest possible character
                        .whereField("username", isNotEqualTo: currentUsername) // Exclude the current user's username
                        .getDocuments { (snapshot, error) in
                            if let error = error {
                                print("Error fetching users: \(error.localizedDescription)")
                            } else {
                                guard let documents = snapshot?.documents else {
                                    print("No users found")
                                    return
                                }
                                // Extract user data and populate the users array
                                for document in documents {
                                    if let username = document.data()["username"] as? String,
                                       let email = document.data()["email"] as? String {
                                        self.users.append((username: username, email: email))
                                        self.checkIfUserIsAdded(email: email) // Check if the user is already added
                                    }
                                }
                                // Reload table view
                                self.tableView.reloadData()
                            }
                    }
                } else {
                    print("Current user's username not found")
                }
            } else {
                print("Document does not exist")
            }
        }
    }


    private func checkIfUserIsAdded(email: String) {
        isUserAlreadyAdded(email: email) { [weak self] isUserAdded in
            self?.userStatusCache[email] = isUserAdded
            self?.updateButtonStates()
        }
    }
    
    private func addUserByEmail(email: String) {
        // Call Firebase function to add user to the list
        addOrRemoveUserToFirebase(userId: currentUser!.uid, email: email, isAdding: true)
    }
    
    private func removeUserByEmail(email: String) {
        // Call Firebase function to remove user from the list
        addOrRemoveUserToFirebase(userId: currentUser!.uid, email: email, isAdding: false)
    }
    
    private func addOrRemoveUserToFirebase(userId: String, email: String, isAdding: Bool) {
        if isAdding {
            // Retrieve the user document based on the provided email
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { [self] snapshot, error in
                if let error = error {
                    print("Error adding user: \(error.localizedDescription)")
                    return
                }

                // Check if user document exists
                guard let document = snapshot?.documents.first else {
                    print("User not found with email: \(email)")
                    return
                }

                // Get the UID of the user
                guard let friendUID = document.data()["uid"] as? String else {
                    print("UID not found for user with email: \(email)")
                    return
                }

                // Add the user to the friend list
                db.collection("users").document(userId).collection("friends").document(friendUID).setData(["email": email, "uid": friendUID]) { error in
                    if let error = error {
                        print("Error adding user to friend list: \(error.localizedDescription)")
                    } else {
                        print("User added successfully to friend list")
                    }
                }
            }
        } else {
            // Retrieve the user document based on the provided email
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { [self] snapshot, error in
                if let error = error {
                    print("Error removing user: \(error.localizedDescription)")
                    return
                }

                // Check if user document exists
                guard let document = snapshot?.documents.first else {
                    print("User not found with email: \(email)")
                    return
                }

                // Get the UID of the user
                guard let friendUID = document.data()["uid"] as? String else {
                    print("UID not found for user with email: \(email)")
                    return
                }

                // Remove the user from the friend list
                db.collection("users").document(userId).collection("friends").document(friendUID).delete { [self] error in
                    if let error = error {
                        print("Error removing user from friend list: \(error.localizedDescription)")
                        return
                    }

                    // Fetch all goals for the current user
                    db.collection("users").document(userId).collection("goals").getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching goals: \(error.localizedDescription)")
                            return
                        }

                        guard let documents = snapshot?.documents else { return }

                        let dispatchGroup = DispatchGroup()

                        // Iterate through the goals and check if the friend is a viewer
                        for document in documents {
                            let data = document.data()
                            if let viewers = data["viewers"] as? [String: Bool], viewers.keys.contains(friendUID) {
                                let documentID = document.documentID
                                dispatchGroup.enter()
                                self.db.collection("users").document(userId).collection("goals").document(documentID).updateData([
                                    "viewers.\(friendUID)": FieldValue.delete()
                                ]) { error in
                                    if let error = error {
                                        print("Error removing viewer from goal \(documentID): \(error.localizedDescription)")
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }

                        dispatchGroup.notify(queue: .main) {
                            print("User removed successfully from friend list and as viewer from goals")
                        }
                    }
                }
            }
        }
    }

}

extension FindUsersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        findUsers(withUsername: searchText)
    }
    
    private func isUserAlreadyAdded(email: String, completion: @escaping (Bool) -> Void) {
        // Check if the user's email exists in your friend list
        db.collection("users").document(currentUserID).collection("friends").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking user: \(error.localizedDescription)")
                completion(false)
            } else {
                // Check if any documents exist
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // User is already added to the friend list
                    completion(true)
                    print("friend in list \(email)")
                } else {
                    // User is not added to the friend list
                    completion(false)
                    print("friend not in list \(email)")

                }
            }
        }
    }
    
    private func updateButtonStates() {
        // Reload table view to update button states
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension FindUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user = users[indexPath.row]
        let username = user.username
        let email = user.email
        
        cell.textLabel?.text = username
        
        let isUserAdded = userStatusCache[email] ?? false // Use cached value
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: cell.contentView.bounds.width - 80, y: 5, width: 70, height: 30)
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        
        // Set button title and background color based on whether the user is added or not
        let actionTitle = isUserAdded ? "Remove" : "Add"
        button.backgroundColor = isUserAdded ? .red : .black
        button.setTitle(actionTitle, for: .normal)
        
        button.tag = indexPath.row // Set the tag to identify the button
        button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        // Remove any existing buttons from cell's contentView
        cell.contentView.subviews.forEach { view in
            if view is UIButton {
                view.removeFromSuperview()
            }
        }
        
        // Add the button to the cell's contentView
        cell.contentView.addSubview(button)
        
        return cell
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag // Get the index from the button's tag
        let email = users[index].email
        
        let isUserAdded = userStatusCache[email] ?? false
        let actionTitle = isUserAdded ? "Remove" : "Add"
        print("\(actionTitle) button tapped for user: \(email)")
        buttonAction?(email, !isUserAdded) // Trigger the closure with user's email and action status
        findUsers(withUsername: searchBar.text ?? "")
    }
}

extension FindUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

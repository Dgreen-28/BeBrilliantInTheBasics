//
//  AddViewersViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 5/15/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class AddViewersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: AddViewersViewControllerDelegate?
    var tableView: UITableView!
    var friends: [Friend] = [] // Define a data source for your table view
    var goal: GoalCloud?
    private var db = Firestore.firestore()
    var addingFriends: [String] = [] // Array to keep track of friends being added as viewers
    var friendsToAdd: [String] = []
    var viewersEdited: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Users"
        print(friendsToAdd)
        if let goal = goal {
            addingFriends = goal.viewers
        }
        print(friendsToAdd)
        // Initialize table view
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        view.addSubview(tableView)
        view.backgroundColor = .white
        
        // Add save button
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .accent
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Add the info button
        let infoButton = UIButton(type: .system)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.tintColor = .darkGray
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        view.addSubview(infoButton)
        
        // Position save and info button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            infoButton.widthAnchor.constraint(equalToConstant: 35),
            infoButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        // Add constraints to tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10)
        ])
        // Call your function to fetch and display friends
        fetchFriends()
        // Create and set the Cancel button
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
        
    }
    @objc func infoButtonTapped() {
        let infopageVC = InfoPageViewController()
        infopageVC.infoText = "add Viewers Page" // Pass the appropriate case identifier
        infopageVC.modalPresentationStyle = .overCurrentContext
        infopageVC.modalTransitionStyle = .crossDissolve
        present(infopageVC, animated: true, completion: nil)
    }
    @objc func cancelButtonTapped() {
        // Handle the cancel action, usually by popping the view controller
        self.navigationController?.popViewController(animated: true)
    }
    func addFriendsAsViewersToGoal(goalID: String, friendEmails: [String], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        // Retrieve the goal document
        db.collection("goals").document(goalID).getDocument { (goalSnapshot, goalError) in
            if let goalError = goalError {
                completion(goalError)
                return
            }
            
            guard let goalDocument = goalSnapshot else {
                completion(nil)
                return
            }
            
            // Check if the current user is the owner of the goal
            guard let goalOwnerID = goalDocument.data()?["ownerID"] as? String, goalOwnerID == currentUserID else {
                // If the current user is not the owner of the goal, return without adding viewers
                completion(nil)
                return
            }
            
            // Retrieve the user documents based on the provided emails
            db.collection("users").whereField("email", in: friendEmails).getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Get an array of friend UIDs
                let friendUIDs = snapshot?.documents.compactMap { $0.data()["uid"] as? String } ?? []
                
                // Add each friend as a viewer to the goal
                for friendUID in friendUIDs {
                    let data: [String: Any] = [
                        "viewers.\(friendUID)": true
                    ]
                    
                    // Update the goal document to add the friend as a viewer
                    db.collection("goals").document(goalID).setData(data, merge: true) { error in
                        if let error = error {
                            print("Error adding viewer to goal: \(error.localizedDescription)")
                        }
                    }
                }
                
                completion(nil) // Completion after all viewers are added
            }
        }
    }

    // Function to fetch friends and update the table view
    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }

        // Query the collection of friends for the current user
        db.collection("users").document(userId).collection("friends").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                return
            }

            // Clear existing friends
            self.friends.removeAll()

            guard let documents = snapshot?.documents else {
                print("No friends found")
                return
            }

            // Create a dispatch group
            let dispatchGroup = DispatchGroup()

            // Fetch usernames for each friend UID
            for document in documents {
                guard let email = document.data()["email"] as? String,
                      let uid = document.data()["uid"] as? String else {
                    continue
                }

                dispatchGroup.enter() // Enter the dispatch group before starting the fetch
                self.db.collection("users").document(uid).getDocument { userSnapshot, error in
                    defer { dispatchGroup.leave() } // Leave the dispatch group after the fetch is done
                    
                    if let error = error {
                        print("Error fetching username for \(uid): \(error.localizedDescription)")
                        return
                    }

                    var username = "Unknown"
                    if let fetchedUsername = userSnapshot?.data()?["username"] as? String {
                        username = fetchedUsername
                    }
                    if self.viewersEdited == true {
                        let isViewer = self.friendsToAdd.contains(uid)
                        let friend = Friend(email: email, uid: uid, username: username, isViewer: isViewer)
                        self.friends.append(friend)
                    } else {
                        let isViewer = self.goal?.viewers.contains(uid) ?? false
                        let friend = Friend(email: email, uid: uid, username: username, isViewer: isViewer)
                        self.friends.append(friend)
                    }

//                    let isViewer = self.goal?.viewers.contains(uid) ?? false
//                    let friend = Friend(email: email, uid: uid, username: username, isViewer: isViewer)
//                    self.friends.append(friend)
                }
            }

                dispatchGroup.notify(queue: .main) {
                    self.friends.sort { $0.username < $1.username }
                    self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]
        cell.configure(with: friend, index: indexPath.row, target: self, action: #selector(handleActionButtonTapped(_:)))
        return cell
    }

    @objc func handleActionButtonTapped(_ sender: UIButton) {
        let friend = friends[sender.tag]
        
        if friend.isViewer {
            // If the friend is already a viewer, remove them from addingFriends
            if let index = addingFriends.firstIndex(of: friend.uid) {
                addingFriends.remove(at: index)
            }
            // Remove friend's UID from friendsToAdd
            if let index = friendsToAdd.firstIndex(of: friend.uid) {
                friendsToAdd.remove(at: index)
            }
            
            friends[sender.tag].isViewer = false
            sender.setTitle("Add", for: .normal)
        } else {
            // If the friend is not a viewer, add them to addingFriends
            addingFriends.append(friend.uid)
            friendsToAdd.append(friend.uid)
            friends[sender.tag].isViewer = true
            sender.setTitle("Remove", for: .normal)
        }
        
        // Print the updated addingFriends array
        print("Adding Friends: \(addingFriends)")
        
    }
    
    // MARK: - Button Action
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        // Update the friendsToAdd array
        if self.viewersEdited == true {
            delegate?.didUpdateViewers(friendsToAdd)

        } else {
            delegate?.didUpdateViewers(addingFriends)
        }
            
        delegate?.didEditViewers()

        // Dismiss the view controller
        self.navigationController?.popViewController(animated: true)
    }
}

class FriendCell: UITableViewCell {
    let actionButton: UIButton

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        actionButton = UIButton(type: .system)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with friend: Friend, index: Int, target: Any?, action: Selector) {
        textLabel?.text = friend.username
//        textLabel?.text = "\(friend.username) (\(friend.email))"
        actionButton.setTitle(friend.isViewer ? "Remove" : "Add", for: .normal)
        actionButton.tag = index
        actionButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
protocol AddViewersViewControllerDelegate: AnyObject {
    func didUpdateViewers(_ viewers: [String])
    func didEditViewers()
}

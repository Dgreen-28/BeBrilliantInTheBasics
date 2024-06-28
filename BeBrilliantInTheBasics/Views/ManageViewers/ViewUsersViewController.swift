//
//  ViewUsersViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 5/22/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class ViewUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var friends: [Friend] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Added Users"

        setupTableView()
        fetchFriends()
    }

    func setupTableView() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ViewFriendCell.self, forCellReuseIdentifier: ViewFriendCell.identifier)
        self.view.addSubview(tableView)
    }

    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }

        db.collection("users").document(userId).collection("friends").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                return
            }

            self.friends.removeAll()

            guard let documents = snapshot?.documents else {
                print("No friends found")
                return
            }

            let dispatchGroup = DispatchGroup()

            for document in documents {
                guard let email = document.data()["email"] as? String,
                      let uid = document.data()["uid"] as? String else {
                    continue
                }

                dispatchGroup.enter()
                self.db.collection("users").document(uid).getDocument { userSnapshot, error in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        print("Error fetching username for \(uid): \(error.localizedDescription)")
                        return
                    }

                    var username = "Unknown"
                    if let fetchedUsername = userSnapshot?.data()?["username"] as? String {
                        username = fetchedUsername
                    }

                    let friend = Friend(email: email, uid: uid, username: username, isViewer: false)
                    self.friends.append(friend)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.friends.sort { $0.username < $1.username }
//            dispatchGroup.notify(queue: .main) {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewFriendCell.identifier, for: indexPath) as? ViewFriendCell else {
            return UITableViewCell()
        }
        
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.username
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeFriendButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle cell selection if needed
    }

    @objc func removeFriendButtonTapped(_ sender: UIButton) {
        let friendIndex = sender.tag
        let friend = friends[friendIndex]
        removeFriend(friend: friend)
    }

    func removeFriend(friend: Friend) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }

        let friendUID = friend.uid

        // Remove friend from friends collection
        db.collection("users").document(userId).collection("friends").document(friendUID).delete { [weak self] error in
            if let error = error {
                print("Error removing friend: \(error.localizedDescription)")
                return
            }

            // Fetch all goals for the current user
            self?.db.collection("users").document(userId).collection("goals").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                // Create a dispatch group to handle multiple asynchronous operations
                let dispatchGroup = DispatchGroup()

                // Iterate through the goals and check if the friend is a viewer
                for document in documents {
                    let data = document.data()
                    if let viewers = data["viewers"] as? [String: Bool], viewers.keys.contains(friendUID) {
                        let documentID = document.documentID
                        dispatchGroup.enter()
                        self?.db.collection("users").document(userId).collection("goals").document(documentID).updateData([
                            "viewers.\(friendUID)": FieldValue.delete()
                        ]) { error in
                            if let error = error {
                                print("Error removing viewer from goal \(documentID): \(error.localizedDescription)")
                            }
                            dispatchGroup.leave()
                        }
                    }
                }

                // Notify when all goals have been updated
                dispatchGroup.notify(queue: .main) {
                    // Update local data source and reload table view
                    self?.friends.removeAll { $0.uid == friendUID }
                    self?.tableView.reloadData()
                    print("Friend and viewer references removed successfully")
                }
            }
        }
    }
}


class ViewFriendCell: UITableViewCell {
    static let identifier = "ViewFriendCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

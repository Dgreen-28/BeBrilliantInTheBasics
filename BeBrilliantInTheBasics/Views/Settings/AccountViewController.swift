//
//  AccountViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 6/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Elements
    private let tableView = UITableView()
    private var currentUsername: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Account Information"

        setupTableView()
        fetchCurrentUsername()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchCurrentUsername() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { document, error in
            if let error = error {
                print("Error fetching username: \(error.localizedDescription)")
            } else if let document = document, let data = document.data() {
                self.currentUsername = data["username"] as? String
                self.tableView.reloadData()
            }
        }
    }
    
    // TableView DataSource and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "usernameCell")
            cell.textLabel?.text = currentUsername
            cell.detailTextLabel?.text = "Change Username"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Change Password"
            case 1:
                cell.textLabel?.text = "Delete All Goals"
            case 2:
                cell.textLabel?.text = "Delete Account"
                cell.textLabel?.textColor = .red
//            case 3:
//                cell.textLabel?.text = "Delete Account"
//                cell.textLabel?.textColor = .red
            default:
                break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            changeUsername()
        } else {
            switch indexPath.row {
            case 0:
                changePassword()
            case 1:
                deleteAllGoals()
            case 2:
                deleteAccount()
//            case 3:
//                deleteAccount()
            default:
                break
            }
        }
    }
    
    // Actions
    @objc private func changeUsername() {
        let alert = UIAlertController(title: "Change Username", message: "Enter new username", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New Username"
            textField.autocapitalizationType = .none // Disable autocapitalization
        }
        
        // Declare save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newUsername = alert.textFields?.first?.text, !newUsername.isEmpty else { return }
            
            // Check if username is already in use
            let db = Firestore.firestore()
            db.collection("users").whereField("username", isEqualTo: newUsername.lowercased()).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking username:", error.localizedDescription)
                    self.presentAlert(title: "Error", message: "Error checking username: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Username is already in use.")
                    self.presentAlert(title: "Error", message: "Username is already in use.")
                    return
                }
                
                // If the username is not in use, update the username
                self.updateUsername(newUsername.lowercased())
            }
        }
        
        // Declare cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
//    @objc private func changeUsername() {
//        let alert = UIAlertController(title: "Change Username", message: "Enter new username", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "New Username"
//            textField.autocapitalizationType = .none // Disable autocapitalization
//
//        }
//        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//            guard let newUsername = alert.textFields?.first?.text, !newUsername.isEmpty else { return }
//            self.updateUsername(newUsername.lowercased())
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
//    }
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @objc private func changePassword() {
        let alertController = UIAlertController(title: "Change Password", message: "Enter your email to reset your password.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
            guard let email = alertController.textFields?.first?.text, !email.isEmpty else {
                self.presentAlert(title: "Error", message: "Email field cannot be empty.")
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self.presentAlert(title: "Success", message: "Password reset email sent.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
            //        let alert = UIAlertController(title: "Change Password", message: "Enter new password", preferredStyle: .alert)
            //        alert.addTextField { textField in
            //            textField.placeholder = "New Password"
            //            textField.isSecureTextEntry = true
            //        }
            //        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            //            guard let newPassword = alert.textFields?.first?.text, !newPassword.isEmpty else { return }
            //            self.updatePassword(newPassword)
            //        }
            //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //        alert.addAction(saveAction)
            //        alert.addAction(cancelAction)
            //        present(alert, animated: true, completion: nil)
        
    }
    @objc private func deleteAllGoals() {
        let alert = UIAlertController(title: "Delete All Goals", message: "Are you sure you want to delete all your goals?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.performDeleteAllGoals()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func removeSelfFromGoals() {
        let alert = UIAlertController(title: "Remove Self from Goals", message: "Are you sure you want to remove yourself from all goals?", preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.performRemoveSelfFromGoals()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.performDeleteAccount()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateUsername(_ newUsername: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).updateData(["username": newUsername]) { error in
            if let error = error {
                print("Error updating username: \(error.localizedDescription)")
            } else {
                print("Username updated successfully")
                self.currentUsername = newUsername
                self.tableView.reloadData()
            }
        }
    }
    
    private func updatePassword(_ newPassword: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error updating password: \(error.localizedDescription)")
            } else {
                print("Password updated successfully")
            }
        }
    }
    private func performDeleteAllGoals() {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where there's no logged-in user
            return
        }
        
        let db = Firestore.firestore()
        
        // Fetch all goals for the current user
        db.collection("users").document(currentUser.uid).collection("goals").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching goals: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No goals found to delete")
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let goalIdToDelete = document.documentID
                print("Goal ID to delete: \(goalIdToDelete)")
                
                db.collection("users").document(currentUser.uid).collection("goals").document(goalIdToDelete).delete() { error in
                    if let error = error {
                        print("Error deleting goal: \(error.localizedDescription)")
                    } else {
                        print("Goal:\(goalIdToDelete) deleted successfully")
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Notify when all deletions are done
            dispatchGroup.notify(queue: .main) {
                print("All goals deleted successfully")
            }
        }
    }

//    private func performDeleteAllGoals() {
//        guard let currentUser = Auth.auth().currentUser else { return }
//        let db = Firestore.firestore()
//        db.collection("users").document(currentUser.uid).collection("goals").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching goals: \(error.localizedDescription)")
//                return
//            }
//            guard let documents = snapshot?.documents else { return }
//            for document in documents {
//                document.reference.delete { error in
//                    if let error = error {
//                        print("Error deleting goal: \(error.localizedDescription)")
//                    }
//                }
//            }
//            print("All goals deleted successfully")
//        }
//    }
    
    private func performRemoveSelfFromGoals() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("goals").whereField("viewers", arrayContains: currentUser.uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching goals: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                document.reference.updateData(["viewers": FieldValue.arrayRemove([currentUser.uid])]) { error in
                    if let error = error {
                        print("Error removing self from goal: \(error.localizedDescription)")
                    }
                }
            }
            print("Removed self from all goals successfully")
        }
    }
    
    private func performDeleteAccount() {
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.delete { error in
            if let error = error {
                print("Error deleting account: \(error.localizedDescription)")
            } else {
                print("Account deleted successfully")
            }
        }
    }
}
/*
 //
 //  AccountViewController.swift
 //  BeBrilliantInTheBasics
 //
 //  Created by Decoreyon Green on 6/7/24.
 //

 import UIKit
 import FirebaseAuth
 import FirebaseFirestore

 class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
     // UI Elements
     private let tableView = UITableView()
     private let usernameLabel = UILabel()
     private let usernameTextField = UITextField()
     private var currentUsername: String? {
         didSet {
             usernameTextField.text = currentUsername
         }
     }

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         self.title = "Account Information"

         setupUsernameField()
         setupTableView()
         fetchCurrentUsername()
     }
     
     private func setupUsernameField() {
         usernameLabel.text = "Change Username"
         usernameLabel.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(usernameLabel)
         
         usernameTextField.borderStyle = .roundedRect
         usernameTextField.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(usernameTextField)
         
         let saveButton = UIButton(type: .system)
         saveButton.setTitle("Save", for: .normal)
         saveButton.addTarget(self, action: #selector(saveUsername), for: .touchUpInside)
         saveButton.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(saveButton)
         
         NSLayoutConstraint.activate([
             usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
             usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             
             usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
             usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             
             saveButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10),
             saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
         ])
     }

     
     private func setupTableView() {
         tableView.delegate = self
         tableView.dataSource = self
         tableView.translatesAutoresizingMaskIntoConstraints = false
         tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
         
         view.addSubview(tableView)
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 50),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }
     
     private func fetchCurrentUsername() {
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid).getDocument { document, error in
             if let error = error {
                 print("Error fetching username: \(error.localizedDescription)")
             } else if let document = document, let data = document.data() {
                 self.currentUsername = data["username"] as? String
             }
         }
     }
     
     @objc private func saveUsername() {
         guard let newUsername = usernameTextField.text, !newUsername.isEmpty else { return }
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid).updateData(["username": newUsername]) { error in
             if let error = error {
                 print("Error updating username: \(error.localizedDescription)")
             } else {
                 print("Username updated successfully")
                 self.currentUsername = newUsername
             }
         }
     }
     
     // TableView DataSource and Delegate Methods
     func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 4
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         switch indexPath.row {
         case 0:
             cell.textLabel?.text = "Change Password"
         case 1:
             cell.textLabel?.text = "Delete All Goals"
         case 2:
             cell.textLabel?.text = "Remove Self from Goals"
         case 3:
             cell.textLabel?.text = "Delete Account"
             cell.textLabel?.textColor = .red
         default:
             break
         }
         return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         switch indexPath.row {
         case 0:
             changePassword()
         case 1:
             deleteAllGoals()
         case 2:
             removeSelfFromGoals()
         case 3:
             deleteAccount()
         default:
             break
         }
     }
     
     // Actions
     @objc private func changePassword() {
         let alert = UIAlertController(title: "Change Password", message: "Enter new password", preferredStyle: .alert)
         alert.addTextField { textField in
             textField.placeholder = "New Password"
             textField.isSecureTextEntry = true
         }
         let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
             guard let newPassword = alert.textFields?.first?.text, !newPassword.isEmpty else { return }
             self.updatePassword(newPassword)
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alert.addAction(saveAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
     }
     
     @objc private func deleteAllGoals() {
         let alert = UIAlertController(title: "Delete All Goals", message: "Are you sure you want to delete all your goals?", preferredStyle: .alert)
         let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
             self.performDeleteAllGoals()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alert.addAction(deleteAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
     }
     
     @objc private func removeSelfFromGoals() {
         let alert = UIAlertController(title: "Remove Self from Goals", message: "Are you sure you want to remove yourself from all goals?", preferredStyle: .alert)
         let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
             self.performRemoveSelfFromGoals()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alert.addAction(removeAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
     }
     
     @objc private func deleteAccount() {
         let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
         let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
             self.performDeleteAccount()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alert.addAction(deleteAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
     }
     
     private func updatePassword(_ newPassword: String) {
         guard let currentUser = Auth.auth().currentUser else { return }
         currentUser.updatePassword(to: newPassword) { error in
             if let error = error {
                 print("Error updating password: \(error.localizedDescription)")
             } else {
                 print("Password updated successfully")
             }
         }
     }
     
     private func performDeleteAllGoals() {
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid).collection("goals").getDocuments { snapshot, error in
             if let error = error {
                 print("Error fetching goals: \(error.localizedDescription)")
                 return
             }
             guard let documents = snapshot?.documents else { return }
             for document in documents {
                 document.reference.delete { error in
                     if let error = error {
                         print("Error deleting goal: \(error.localizedDescription)")
                     }
                 }
             }
             print("All goals deleted successfully")
         }
     }
     
     private func performRemoveSelfFromGoals() {
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("goals").whereField("viewers", arrayContains: currentUser.uid).getDocuments { snapshot, error in
             if let error = error {
                 print("Error fetching goals: \(error.localizedDescription)")
                 return
             }
             guard let documents = snapshot?.documents else { return }
             for document in documents {
                 document.reference.updateData(["viewers": FieldValue.arrayRemove([currentUser.uid])]) { error in
                     if let error = error {
                         print("Error removing self from goal: \(error.localizedDescription)")
                     }
                 }
             }
             print("Removed self from all goals successfully")
         }
     }
     
     private func performDeleteAccount() {
         guard let currentUser = Auth.auth().currentUser else { return }
         currentUser.delete { error in
             if let error = error {
                 print("Error deleting account: \(error.localizedDescription)")
             } else {
                 print("Account deleted successfully")
             }
         }
     }
 }

 */

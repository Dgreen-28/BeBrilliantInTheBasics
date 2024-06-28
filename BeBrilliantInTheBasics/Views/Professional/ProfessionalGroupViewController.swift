//
//  ProfessionalGroupViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfessionalGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewerGoals: [GoalCloud] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewerGoalsForFriends()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
    }
    func loadViewerGoalsForFriends() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }

        let db = Firestore.firestore()

        // Query Firestore to fetch user's friend list
        db.collection("users").document(currentUser.uid).collection("friends").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching friend list: \(error.localizedDescription)")
                return
            }

            print("Friend list fetched successfully")

            // Clear the existing viewerGoals array
            self?.viewerGoals.removeAll()

            // Iterate through fetched documents (friends) and load goals for each friend
            for document in querySnapshot!.documents {
                let friendUID = document.documentID
                print("Friend UID: \(friendUID)")

                // Query Firestore to fetch goals where the friend is a viewer
                db.collection("users").document(friendUID).collection("goals")
                    .whereField("goalType", isEqualTo: "Professional")
                    .whereField("viewers.\(currentUser.uid)", isEqualTo: true) // Filter goals where current user is a viewer
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching goals for friend \(friendUID): \(error.localizedDescription)")
                            return
                        }

                        print("Goals fetched successfully for viewer \(currentUser.uid)")

                        // Iterate through fetched documents (goals for friend) and parse them into GoalCloud objects
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let name = data["name"] as? String ?? ""
                            let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                            let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let goalType = data["goalType"] as? String ?? ""
                            let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
                            let checkInSchedule = data["checkInSchedule"] as? String ?? ""
                            let checkInQuestion = data["checkInQuestion"] as? String ?? ""
                            let isComplete: String

                            // Convert boolean to string if needed
                            if let isCompleteBool = data["isComplete"] as? Bool {
                                isComplete = isCompleteBool ? "true" : "false"
                            } else {
                                isComplete = data["isComplete"] as? String ?? ""
                            }
                            let goal = GoalCloud(name: name,
                                                 startDate: startDate,
                                                 endDate: endDate,
                                                 goalType: goalType,
                                                 checkInSuccessRate: checkInSuccessRate,
                                                 checkInSchedule: checkInSchedule,
                                                 checkInQuestion: checkInQuestion,
                                                 isComplete: isComplete,
                                                 checkInHistory: [],
                                                 viewers: [],
                                                 ownerName: nil,
                                                 ownerUID: friendUID) // Set the owner UID

                            // Append the parsed goal to viewerGoals array
                            self?.viewerGoals.append(goal)

                            // Fetch owner's username and update the goal
                            self?.fetchOwnerUsername(for: friendUID) { username in
                                if let index = self?.viewerGoals.firstIndex(where: { $0.name == name }) {
                                    self?.viewerGoals[index].ownerName = username
                                    self?.tableView.reloadData()
                                }
                            }
                        }

                        // Print the number of goals fetched for the friend
                        print("Number of goals fetched for \(friendUID): \(self?.viewerGoals.count ?? 0)")

                        // Sort the userGoals array by startDate in descending order
                        self?.viewerGoals.sort(by: { $0.startDate > $1.startDate })
                        
                        // Reload table view after fetching goals for the friend
                        self?.tableView.reloadData()
                    }
            }
        }
    }


    func fetchOwnerUsername(for ownerUID: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(ownerUID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching owner's username for \(ownerUID): \(error.localizedDescription)")
                return
            }
            if let username = snapshot?.data()?["username"] as? String {
                completion("@\(username)") // Prepend "@" to each username
            } else {
                completion("")
            }
        }
    }



 }

 extension ProfessionalGroupViewController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewerGoals.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
         let goal = viewerGoals[indexPath.row]
         cell.contentView.backgroundColor = .folderYellow
         
         cell.goalLabel.text = goal.name
         cell.bottomView.isHidden = false
         cell.viewerImage.image = UIImage(named: "eye")
         cell.viewerLabel.text = goal.ownerName ?? "" // Set the owner's username here

         if goal.isComplete == "true" {
             cell.statusImage.image = UIImage(named: "GreenCheck")
         }
         else if goal.isComplete == "false" {
             cell.statusImage.image = UIImage(named: "RedCheck")
         }
         else {
             switch goal.checkInSuccessRate {
             case 80.0...:
                 cell.statusImage.image = UIImage(named: "Green")
             case 65.0..<80.0:
                 cell.statusImage.image = UIImage(named: "Yellow")
             default:
                 cell.statusImage.image = UIImage(named: "Red")
             }
         }
         
         print("tapped\(indexPath.row)")
         
         return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let goal = viewerGoals[indexPath.row]
         print("tapped \(indexPath.row)")
         let checkInDataVC = CheckInDataViewController()
         checkInDataVC.goal = goal
         checkInDataVC.isViewer = true
         checkInDataVC.ownerUID = goal.ownerUID ?? ""
         checkInDataVC.hidesBottomBarWhenPushed = true
         checkInDataVC.goalTitle = goal.name // Pass the goal title
         self.navigationController?.pushViewController(checkInDataVC, animated: true)
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 90 // Set the height of the table view cell to 100
     }
     func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
         let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { (_) -> UIMenu? in
             let deleteAction = UIAction(
                 title: "Remove From Goal",
                 image: UIImage(systemName: "trash"),
                 attributes: .destructive) { [weak self] _ in
                     guard let self = self else { return }
                     let goalToDelete = self.viewerGoals[indexPath.row]
                     print("Goal to delete: \(goalToDelete)")
                     
                     let alert = UIAlertController(title: "Delete Goal", message: "Are you sure you want to be removed from this goal?", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                     alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                         let db = Firestore.firestore()
                         guard let currentUser = Auth.auth().currentUser else {
                             // Handle the case where there's no logged-in user
                             return
                         }
                         
                         // Update the viewers field of the goal document
                         db.collection("users").document(goalToDelete.ownerUID!).collection("goals")
                             .whereField("name", isEqualTo: goalToDelete.name)
                             .getDocuments { (snapshot, error) in
                                 if let error = error {
                                     print("Error getting documents: \(error.localizedDescription)")
                                 } else {
                                     guard let snapshot = snapshot else { return }
                                     for document in snapshot.documents {
                                         let goalDocumentRef = document.reference
                                         goalDocumentRef.updateData([
                                             "viewers.\(currentUser.uid)": FieldValue.delete()
                                         ]) { error in
                                             if let error = error {
                                                 print("Error removing viewer: \(error.localizedDescription)")
                                             } else {
                                                 print("Successfully removed viewer from goal")
                                                 self.viewerGoals.remove(at: indexPath.row)
                                                 tableView.deleteRows(at: [indexPath], with: .automatic)
                                                 tableView.reloadData()
                                             }
                                         }
                                     }
                                 }
                             }
                     }))
                     self.present(alert, animated: true, completion: nil)
                 }
             return UIMenu(title: "", children: [deleteAction])
         }
         return config
     }

 }

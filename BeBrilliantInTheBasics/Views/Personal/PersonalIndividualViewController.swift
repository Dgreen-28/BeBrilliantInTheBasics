//
//  PersonalIndividualViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/5/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class PersonalIndividualViewController: UIViewController {
    var userGoals: [GoalCloud] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserGoals()
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        
        // Load user's goals
//        loadUserGoals()
    }
    func loadUserGoals() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        // Query Firestore to fetch user's personal goals based on user ID and goal type
        db.collection("users").document(currentUser.uid).collection("goals")
            .whereField("goalType", isEqualTo: "Personal")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching user personal goals: \(error.localizedDescription)")
                    return
                }
                
                // Clear the existing userGoals array
                self.userGoals.removeAll()
                
                // Iterate through fetched documents and parse them into GoalCloud objects
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let name = data["name"] as? String ?? ""
                    let startDate = data["startDate"] as? Date ?? Date()
                    let endDate = data["endDate"] as? Date ?? Date()
                    let goalType = data["goalType"] as? String ?? ""
                    let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
                    let checkInSchedule = data["checkInSchedule"] as? String ?? ""
                    let checkInQuestion = data["checkInQuestion"] as? String ?? ""
                    let isComplete = data["isComplete"] as? Bool ?? false
                    let viewersData = data["viewers"] as? [String: Bool] ?? [:]
                    
                    // Extract viewer IDs
                    let viewerIDs = Array(viewersData.keys)
                    
                    let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: [], viewers: viewerIDs)
                    
                    // Append the parsed goal to userGoals array
                    self.userGoals.append(goal)
                }
                
                // Reload table view after fetching user's goals
                self.tableView.reloadData()
            }
    }
    
    func deleteGoalFromFirebase(goalId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("goals").document(goalId).delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

extension PersonalIndividualViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
        cell.selectionStyle = .none
        // Set selected background view to clear color
        cell.selectedBackgroundView?.isHidden = true
        let goal = userGoals[indexPath.row]
        cell.contentView.backgroundColor = .folderGreen
        // Reset cell state
        cell.goalLabel.text = ""
        cell.statusImage.image = nil
        cell.viewerLabel.text = ""
        cell.viewerImage.isHidden = true
        cell.bottomView.isHidden = true
        
        // Configure the cell with goal data
        cell.goalLabel.text = goal.name

        if !goal.viewers.isEmpty {
            cell.bottomView.isHidden = false
            cell.viewerImage.isHidden = false
            cell.viewerLabel.text = "Viewers: \(goal.viewers.count)"
            cell.viewerImage.image = UIImage(named: "crown")
        }

        switch goal.checkInSuccessRate {
        case 80.0...:
            cell.statusImage.image = UIImage(named: "Green")
        case 65.0..<80.0:
            cell.statusImage.image = UIImage(named: "Yellow")
        default:
            cell.statusImage.image = UIImage(named: "Red")
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = userGoals[indexPath.row]
        print("tapped \(indexPath.row)")
        
            let checkInDataVC = CheckInDataViewController()
            checkInDataVC.goal = goal
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
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let goalToDelete = self.userGoals[indexPath.row]
                    print("Goal to delete: \(goalToDelete)")
                    
                    let alert = UIAlertController(title: "Delete Goal", message: "Are you sure you want to delete this goal?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                        let db = Firestore.firestore()
                        guard let currentUser = Auth.auth().currentUser else {
                            // Handle the case where there's no logged-in user
                            return
                        }
                        db.collection("users").document(currentUser.uid).collection("goals").whereField("name", isEqualTo: goalToDelete.name).getDocuments { (snapshot, error) in
                            if let error = error {
                                print("Error getting documents: \(error.localizedDescription)")
                            } else {
                                guard let snapshot = snapshot else { return }
                                for document in snapshot.documents {
                                    let goalIdToDelete = document.documentID
                                    print("Goal ID to delete: \(goalIdToDelete)")
                                    db.collection("users").document(currentUser.uid).collection("goals").document(goalIdToDelete).delete() { error in
                                        if let error = error {
                                            print("Error deleting goal: \(error.localizedDescription)")
                                        } else {
                                            print("Goal:\(goalIdToDelete) deleted successfully")
                                            self.userGoals.remove(at: indexPath.row)
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
            
            let editAction = UIAction(
                title: "Edit Goal",
                image: UIImage(systemName: "pencil")) { [weak self] _ in
                    guard let self = self else { return }
                    let goalToView = self.userGoals[indexPath.row]
                    
                    // Instantiate AddGoalViewController from storyboard
                    if let editVC = storyboard?.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController {
                        // Pass the selected goal to AddGoalViewController
                        editVC.goal = goalToView
                        // Check if goalTextField is nil
                        if editVC.goalTextField == nil {
                            print("goalTextField is nil")
                        } else {
                            print("goalTextField is not nil")
                        }
                        // Present AddGoalViewController
                        navigationController?.pushViewController(editVC, animated: true)
                    }
                }
            let checkInAction = UIAction(
                title: "Manual Check in",
                image: UIImage(systemName: "list.bullet.clipboard")) { _ in
                    let goalToCheck = self.userGoals[indexPath.row]

                    let manualCheckinVC = ManualCheckInViewController()
                    manualCheckinVC.goal = goalToCheck
                    manualCheckinVC.hidesBottomBarWhenPushed = true
                    manualCheckinVC.goalTitle = goalToCheck.name // Pass the goal title
                    self.navigationController?.pushViewController(manualCheckinVC, animated: true)
                }
            
            let markAsCompletedAction = UIAction(
                title: "Mark as Completed",
                image: UIImage(systemName: "checkmark.circle")) { _ in
                    // Implement mark as completed action if needed
                    // This closure will be called when the "Mark as Completed" action is selected from the context menu
                }

            let markAsIncompleteAction = UIAction(
                title: "Mark as Incomplete",
                image: UIImage(systemName: "circle")) { _ in
                    // Implement mark as incomplete action if needed
                    // This closure will be called when the "Mark as Incomplete" action is selected from the context menu
                }

            return UIMenu(title: "", children: [deleteAction, editAction, checkInAction, markAsCompletedAction, markAsIncompleteAction])
        }
        
        
        return config
    }
}

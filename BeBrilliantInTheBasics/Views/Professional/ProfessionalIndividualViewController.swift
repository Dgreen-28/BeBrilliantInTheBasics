//
//  ProfessionalIndividualViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class ProfessionalIndividualViewController: UIViewController {
    var userGoals: [GoalCloud] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserGoals()
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.backgroundColor = UIColor.clear
        loadUserGoals()

        // Do any additional setup after loading the view.
    }
    func loadUserGoals() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        // Query Firestore to fetch user's personal goals based on user ID and goal type
        db.collection("users").document(currentUser.uid).collection("goals")
            .whereField("goalType", isEqualTo: "Professional")
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
                    let isComplete = data["isComplete"] as? Bool
                    
                    let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: [])

                    // Append the parsed goal to userGoals array
                    self.userGoals.append(goal)
                }
                
                // Reload table view after fetching user's goals
                self.tableView.reloadData()
            }
    }

}
extension ProfessionalIndividualViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell

        let goal = userGoals[indexPath.row]
        cell.goalLabel.text = goal.name
        // Set other cell properties based on goal data
//        cell.statusImage.isHidden = true
        switch goal.checkInSuccessRate {
        case 80.0...:
            cell.statusImage.image = UIImage(named: "Green")
        case 65.0..<80.0:
            cell.statusImage.image = UIImage(named: "Yellow")
        default:
            cell.statusImage.image = UIImage(named: "Red")
        }
//        cell.statusImage.image = UIImage(named: "Green")
        cell.statusButton.setImage(UIImage(named: "Red"), for: .normal)
        cell.statusButton.isHidden = true
        cell.statusBtn = {[unowned self] in
            let goals = self.userGoals[indexPath.row]
//            cell.statusButton.setImage(UIImage(named: cell.isCheckboxChecked ? "Checkbox_A" : "Checkbox_B"), for: .normal)
            print("tapped\(indexPath.row)")
            
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = userGoals[indexPath.row]
        print("tapped \(indexPath.row)")

        // Instantiate AddGoalViewController from storyboard
        if let editVC = storyboard?.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController {
            // Pass the selected goal to AddGoalViewController
            editVC.goal = goal

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



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Set the height of the table view cell to 100
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
                                        }
                                    }
                                }
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            
            let checkHistoryAction = UIAction(
                title: "View Check in History",
                image: UIImage(systemName: "book")) { [weak self] _ in
                    guard let self = self else { return }
                    // Navigate to CheckInDataViewController
                    let goalToView = self.userGoals[indexPath.row]
                    print("Goal to delete: \(goalToView)")
                    
                    let checkInDataVC = CheckInDataViewController()
                    checkInDataVC.goal = goalToView
                    checkInDataVC.hidesBottomBarWhenPushed = true
                    checkInDataVC.goalTitle = goalToView.name // Pass the goal title
                    // Fetch and pass check-in data
                    // Replace this with your own method to fetch check-in data
                    // Example: checkInDataVC.checkInData = self.fetchCheckInData(for: goalToDelete)
                    self.navigationController?.pushViewController(checkInDataVC, animated: true)
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

            return UIMenu(title: "", children: [deleteAction, checkHistoryAction, markAsCompletedAction, markAsIncompleteAction])
        }
        return config
    }
}

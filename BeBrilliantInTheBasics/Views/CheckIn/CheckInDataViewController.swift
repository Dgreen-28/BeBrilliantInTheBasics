//
//  CheckInDataViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 4/5/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CheckInDataViewController: UIViewController {
    
    var tableView: UITableView!
    
    var goal: GoalCloud?
    var goalTitle: String?
    var checkInData: [GoalCheckin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         // Set up the table view
         tableView = UITableView()
         tableView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(tableView)
         
         // Set constraints for the table view
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
         
         // Register custom table view cell
         tableView.register(CheckInTableViewCell.self, forCellReuseIdentifier: CheckInTableViewCell.reuseIdentifier)
         
         // Set the delegate and data source
         tableView.dataSource = self
         tableView.delegate = self
         
         // Set the title to the goal title
         self.title = goalTitle
         
         // Calculate check-in success rate and format as percentage
        let formattedSuccessRate = formatCheckInSuccessRate(goal!.checkInSuccessRate)
         
        // Add check-in success rate label to the navigation bar
        let successRateLabel = UILabel()
        successRateLabel.textColor = .black // Set color as needed
        successRateLabel.font = UIFont(name: "Helvetica", size: 14) // Set font to Helvetica
        successRateLabel.text = formattedSuccessRate
         
         // Create a container view to hold the label
         let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
         containerView.addSubview(successRateLabel)
         // Set label's frame to fit within container view
         successRateLabel.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
         // Create a bar button item with the container view
         let successRateItem = UIBarButtonItem(customView: containerView)
         // Add the bar button item to the right side of the navigation bar
         navigationItem.rightBarButtonItem = successRateItem
         
        // Load check-in data
        loadCheckInData()
    }
    
    func formatCheckInSuccessRate(_ successRate: Double) -> String {
        // Round the success rate to one decimal place
        let roundedRate = String(format: "%.1f", successRate)
        // Append "%" sign to the rounded rate
        return "\(roundedRate)%"
    }
    
    func loadCheckInData() {
        guard let currentUser = Auth.auth().currentUser,
              let goalName = goal?.name else {
            // Handle the case where there's no logged-in user or goal name is missing
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid)
            .collection("goals").whereField("name", isEqualTo: goalName)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching goal documents: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No goal documents found")
                    return
                }
                
                if let goalDocument = documents.first {
                    let goalId = goalDocument.documentID
                    self.fetchCheckInsForGoal(with: goalId)
                } else {
                    print("Goal document not found for name: \(goalName)")
                }
            }
    }
    
    func fetchCheckInsForGoal(with goalId: String) {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where there's no logged-in user
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid)
            .collection("goals").document(goalId)
            .collection("checkins").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching check-ins: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No check-in documents found")
                    return
                }
                
                self.checkInData = documents.compactMap { document in
                    let data = document.data()
                    guard let goalName = data["goalName"] as? String,
                          let isComplete = data["isComplete"] as? Bool,
                          let timestamp = data["dateCompleted"] as? Timestamp else {
                        return nil
                    }
                    
                    let dateCompleted = timestamp.dateValue()
                    return GoalCheckin(documentID: document.documentID, goalId: goalId, goalName: goalName, isComplete: isComplete, dateCompleted: dateCompleted)
                }

                // Sort the check-in data array by date completed in descending order
                self.checkInData.sort(by: { $0.dateCompleted > $1.dateCompleted })
                
                // Reload the table view once data is fetched and sorted
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

// Extension for table view data source and delegate methods
extension CheckInDataViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckInTableViewCell.reuseIdentifier, for: indexPath) as! CheckInTableViewCell
        let checkIn = checkInData[indexPath.row]
        
        // Configure the cell
        cell.configure(with: checkIn)
        
        // Add tap gesture recognizer for cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let checkIn = checkInData[indexPath.row]
        
        // Show action sheet for editing or deleting check-in
        let alertController = UIAlertController(title: "Edit Check-In", message: nil, preferredStyle: .actionSheet)
        
        let toggleActionTitle = checkIn.isComplete ? "Mark as Incomplete" : "Mark as Completed"
        let toggleAction = UIAlertAction(title: toggleActionTitle, style: .default) { _ in
            // Toggle completion status
            self.toggleCompletionStatus(for: checkIn)
        }
        alertController.addAction(toggleAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Delete the check-in
            self.deleteCheckIn(at: indexPath.row)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func toggleCompletionStatus(for checkIn: GoalCheckin) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser.uid)
            .collection("goals").document(checkIn.goalId)
            .collection("checkins").document(checkIn.documentID ?? "")
            .updateData(["isComplete": !checkIn.isComplete]) { error in
                if let error = error {
                    print("Error updating completion status:", error.localizedDescription)
                } else {
                    print("Completion status updated successfully")
                    // Call the updateGoals() function from FirebaseManager
                    FirebaseManager.shared.updateGoals(currentUser: currentUser) { error in
                        if let error = error {
                            // Handle error
                            print("Error updating goals: \(error.localizedDescription)")
                        } else {
                            // Update successful
                            print("Goals updated successfully!")
                            // Optionally, perform additional actions after updating goals
                        }
                    }
                    // Reload data after update
                    self.loadCheckInData()
                    // Update success rate label
                    self.updateSuccessRateLabel(self.goal!.checkInSuccessRate)
                }
            }
    }


    func deleteCheckIn(at index: Int) {
        let checkIn = checkInData[index]
        print("Deleting check-in:")
        print("Check-in data:", checkIn)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser.uid)
            .collection("goals").document(checkIn.goalId)
            .collection("checkins").document(checkIn.documentID ?? "")
            .delete { error in
                if let error = error {
                    print("Error deleting check-in:", error.localizedDescription)
                } else {
                    print("Check-in deleted successfully")
                    // Call the updateGoals() function from FirebaseManager
                    FirebaseManager.shared.updateGoals(currentUser: currentUser) { error in
                        if let error = error {
                            // Handle error
                            print("Error updating goals: \(error.localizedDescription)")
                        } else {
                            // Update successful
                            print("Goals updated successfully!")
                            // Optionally, perform additional actions after updating goals
                        }
                    }
                    // Remove the check-in from the array and reload data
                    self.checkInData.remove(at: index)
                    self.tableView.reloadData()
                    // Update success rate label
                    self.updateSuccessRateLabel(self.goal!.checkInSuccessRate)
                }
            }
    }
    @objc func changeTitle() {
        navigationItem.rightBarButtonItem?.title = "New Title"
    }
    func updateSuccessRateLabel(_ successRate: Double) {
        let formattedSuccessRate = formatCheckInSuccessRate(successRate)
        if let containerView = navigationItem.rightBarButtonItem?.customView as? UIView,
           let successRateLabel = containerView.subviews.first as? UILabel {
            print("Updating success rate label to: \(formattedSuccessRate)")
            navigationItem.rightBarButtonItem?.title = formattedSuccessRate
            successRateLabel.text = formattedSuccessRate
        } else {
            print("Failed to update success rate label. Container view or label not found.")
        }
    }

}

class CheckInTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CheckInCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with checkIn: GoalCheckin) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy h:mm a"
        let dateString = dateFormatter.string(from: checkIn.dateCompleted)
        let isCompleteText = checkIn.isComplete ? "Completed" : "Incomplete"
        
        titleLabel.text = isCompleteText
        dateLabel.text = dateString
    }
}


/*
 //
 //  CheckInDataViewController.swift
 //  BeBrilliantInTheBasics
 //
 //  Created by Decoreyon Green on 4/5/24.
 //

 import UIKit
 import FirebaseFirestore
 import FirebaseAuth

 class CheckInDataViewController: UIViewController {
     
     var tableView: UITableView!
     
     var goal: GoalCloud?
     var goalTitle: String?
     var checkInData: [GoalCheckin] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // Set up the table view
         tableView = UITableView()
         tableView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(tableView)
         
         // Set constraints for the table view
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
         
         // Register table view cell
         tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CheckInCell")
         
         // Set the delegate and data source
         tableView.dataSource = self
         tableView.delegate = self
         
         // Set the title to the goal title
         self.title = goalTitle
         
         // Load check-in data
         loadCheckInData()
     }
     
     func loadCheckInData() {
         guard let currentUser = Auth.auth().currentUser,
               let goal = goal else {
             // Handle the case where there's no logged-in user or goal is missing
             return
         }
         
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid)
             .collection("goals").document(goal.documentID ?? "")
             .collection("checkins").getDocuments { (snapshot, error) in
                 if let error = error {
                     print("Error fetching check-ins: \(error.localizedDescription)")
                     return
                 }
                 
                 guard let documents = snapshot?.documents else {
                     print("No check-in documents found")
                     return
                 }
                 
                 self.checkInData = documents.compactMap { document in
                     let data = document.data()
                     guard let goalId = data["goalId"] as? String,
                           let goalName = data["goalName"] as? String,
                           let isComplete = data["isComplete"] as? Bool,
                           let dateCompleted = data["dateCompleted"] as? Date else {
                         print("Error parsing check-in document data")
                         return nil
                     }
                     
                     return GoalCheckin(documentID: document.documentID,
                                        goalId: goalId,
                                        goalName: goalName,
                                        isComplete: isComplete,
                                        dateCompleted: dateCompleted)
                 }

                 
                 // Reload the table view once data is fetched
                 DispatchQueue.main.async {
                     self.tableView.reloadData()
                 }
             }
     }
 }

 extension CheckInDataViewController: UITableViewDataSource, UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return checkInData.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell", for: indexPath)
         let checkIn = checkInData[indexPath.row]
         
         // Configure the label text with isComplete and date
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "M/d/yy h:mm a"
         let dateString = dateFormatter.string(from: checkIn.dateCompleted)
         let isCompleteText = checkIn.isComplete ? "Completed" : "Incomplete"
         cell.textLabel?.text = "\(isCompleteText)\n\(dateString)"
         
         // Expand the cell size to accommodate the text
         cell.textLabel?.numberOfLines = 0
         cell.textLabel?.lineBreakMode = .byWordWrapping
         
         // Add tap gesture recognizer for cell
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
         cell.addGestureRecognizer(tapGesture)
         
         return cell
     }
     
     @objc func cellTapped(_ sender: UITapGestureRecognizer) {
         guard let cell = sender.view as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) else { return }
         
         let checkIn = checkInData[indexPath.row]
         let documentId = checkIn.documentID ?? ""
         
         // Show action sheet for editing or deleting check-in
         let alertController = UIAlertController(title: "Edit Check-In", message: nil, preferredStyle: .actionSheet)
         
         let toggleActionTitle = checkIn.isComplete ? "Mark as Incomplete" : "Mark as Completed"
         let toggleAction = UIAlertAction(title: toggleActionTitle, style: .default) { _ in
             // Toggle completion status
             self.toggleCompletionStatus(for: checkIn, documentId: documentId)
         }
         alertController.addAction(toggleAction)
         
         let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
             // Delete the check-in
             self.deleteCheckIn(at: indexPath.row, documentId: documentId)
         }
         alertController.addAction(deleteAction)
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alertController.addAction(cancelAction)
         
         present(alertController, animated: true, completion: nil)
     }
     
     func toggleCompletionStatus(for checkIn: GoalCheckin, documentId: String) {
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid)
             .collection("goals").document(checkIn.goalId)
             .collection("checkins").document(documentId)
             .updateData(["isComplete": !checkIn.isComplete]) { error in
                 if let error = error {
                     print("Error updating completion status: \(error.localizedDescription)")
                 } else {
                     print("Completion status updated successfully")
                     // Reload data after update
                     self.loadCheckInData()
                 }
             }
     }
     
     func deleteCheckIn(at index: Int, documentId: String) {
         guard let currentUser = Auth.auth().currentUser else { return }
         let db = Firestore.firestore()
         db.collection("users").document(currentUser.uid)
             .collection("goals").document(checkInData[index].goalId)
             .collection("checkins").document(documentId)
             .delete { error in
                 if let error = error {
                     print("Error deleting check-in: \(error.localizedDescription)")
                 } else {
                     print("Check-in deleted successfully")
                     // Remove the check-in from the array and reload data
                     self.checkInData.remove(at: index)
                     self.tableView.reloadData()
                 }
             }
     }
 }
*/

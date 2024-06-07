//
//  CheckInIndividualViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class CheckInIndividualViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var checkInGoals: [GoalCloud] = [] // Array to store check-in goals
    var currentDate = Date() // Variable to hold the current date
    let currentUser = Auth.auth().currentUser // Current user

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        loadCheckInGoals(for: currentDate) // Load goals for the current date initially
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.register(UINib(nibName: "DateHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "dateHeaderCell")
        tableView.backgroundColor = UIColor.clear
    }
    func loadCheckInGoals(for date: Date) {
        print("Loading check-in goals for date: \(date)")

        guard let currentUser = currentUser else {
            return
        }

        let db = Firestore.firestore()

        // Retrieve goals from Firestore for the current user
        db.collection("users").document(currentUser.uid).collection("goals")
            .whereField("endDate", isGreaterThanOrEqualTo: date) // Fetch goals with end date greater than or equal to selected date
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching check-in goals: \(error.localizedDescription)")
                    return
                }

                print("Fetched check-in goals successfully")

                // Clear the existing checkInGoals array
                self.checkInGoals.removeAll()

                // Iterate through fetched documents and parse them into GoalCloud objects
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // Check if the viewers field is either missing, an empty map, or an empty array
                    if let viewers = data["viewers"] {
                        if let viewersMap = viewers as? [String: Bool], viewersMap.isEmpty {
                            processGoalDocument(document: document, data: data, date: date)
                        } else if let viewersArray = viewers as? [String], viewersArray.isEmpty {
                            processGoalDocument(document: document, data: data, date: date)
                        }
                    } else {
                        processGoalDocument(document: document, data: data, date: date)
                    }
                }
            }
    }

    private func processGoalDocument(document: DocumentSnapshot, data: [String: Any], date: Date) {
        guard let currentUser = currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        print("Processing goal document: \(document.documentID)")
        let name = data["name"] as? String ?? ""
        print("name \(name)")

        let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
        print("startadate \(startDate)")
        let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
        let goalType = data["goalType"] as? String ?? ""
        let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
        let checkInSchedule = data["checkInSchedule"] as? String ?? ""
        let checkInQuestion = data["checkInQuestion"] as? String ?? ""
        let isComplete = data["isComplete"] as? Bool
        
        var checkInHistory: [GoalCheckin] = []
        
        // Fetch check-ins for the goal
        db.collection("users").document(currentUser.uid).collection("goals").document(document.documentID).collection("checkins")
            .getDocuments { (checkinSnapshot, checkinError) in
                if let checkinError = checkinError {
                    print("Error fetching check-ins: \(checkinError.localizedDescription)")
                    return
                }
                
                for checkinDoc in checkinSnapshot!.documents {
                    let checkinData = checkinDoc.data()
                    let dateCompleted = (checkinData["dateCompleted"] as? Timestamp)?.dateValue() ?? Date()
                    let goalId = checkinData["goalId"] as? String ?? ""
                    let goalName = checkinData["goalName"] as? String ?? ""
                    let isComplete = checkinData["isComplete"] as? Bool ?? false
                    
                    let checkin = GoalCheckin(documentID: checkinDoc.documentID, goalId: goalId, goalName: goalName, isComplete: isComplete, dateCompleted: dateCompleted)
                    checkInHistory.append(checkin)
                }
                
                let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: checkInHistory, viewers: [])

                // Filter the goals based on startDate
                if self.isValidGoal(goal, for: date) {
                    self.checkInGoals.append(goal)
                    print("Processing goal document: \(self.checkInGoals)")
                }
                
                // Reload table view after fetching and filtering check-in goals
                self.tableView.reloadData()
            }
    }

//    func loadCheckInGoals(for date: Date) {
//        print("Loading check-in goals for date: \(date)")
//
//        guard let currentUser = currentUser else {
//            return
//        }
//
//        let db = Firestore.firestore()
//
//        // Retrieve goals from Firestore for the current user
//        db.collection("users").document(currentUser.uid).collection("goals")
//            .whereField("endDate", isGreaterThanOrEqualTo: date) // Fetch goals with end date greater than or equal to selected date
//            // Fetch goals where viewers field is empty
//        
//            .getDocuments { [weak self] (querySnapshot, error) in
//                guard let self = self else { return }
//
//                if let error = error {
//                    print("Error fetching check-in goals: \(error.localizedDescription)")
//                    return
//                }
//
//                print("Fetched check-in goals successfully")
//
//                // Clear the existing checkInGoals array
//                self.checkInGoals.removeAll()
//
//                // Iterate through fetched documents and parse them into GoalCloud objects
//                for document in querySnapshot!.documents {
//                    print("Processing goal document: \(document.documentID)")
//                    let data = document.data()
//                    let name = data["name"] as? String ?? ""
//                    print("name \(name)")
//
//                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
//                    print("startadate \(startDate)")
//                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
//                    let goalType = data["goalType"] as? String ?? ""
//                    let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
//                    let checkInSchedule = data["checkInSchedule"] as? String ?? ""
//                    let checkInQuestion = data["checkInQuestion"] as? String ?? ""
//                    let isComplete = data["isComplete"] as? Bool
//                    
//                    var checkInHistory: [GoalCheckin] = []
//                    
//                    // Fetch check-ins for the goal
//                    db.collection("users").document(currentUser.uid).collection("goals").document(document.documentID).collection("checkins")
//                        .getDocuments { (checkinSnapshot, checkinError) in
//                            if let checkinError = checkinError {
//                                print("Error fetching check-ins: \(checkinError.localizedDescription)")
//                                return
//                            }
//                            
//                            for checkinDoc in checkinSnapshot!.documents {
//                                let checkinData = checkinDoc.data()
//                                let dateCompleted = (checkinData["dateCompleted"] as? Timestamp)?.dateValue() ?? Date()
//                                let goalId = checkinData["goalId"] as? String ?? ""
//                                let goalName = checkinData["goalName"] as? String ?? ""
//                                let isComplete = checkinData["isComplete"] as? Bool ?? false
//                                
//                                let checkin = GoalCheckin(documentID: checkinDoc.documentID, goalId: goalId, goalName: goalName, isComplete: isComplete, dateCompleted: dateCompleted)
//                                checkInHistory.append(checkin)
//                            }
//                            
//                            let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: checkInHistory, viewers: [])
//                            
//                            // Filter the goals based on startDate
//                            if self.isValidGoal(goal, for: date) {
//                                self.checkInGoals.append(goal)
//                                print("Processing goal document: \(self.checkInGoals)")
//                            }
//                            
//                            // Reload table view after fetching and filtering check-in goals
//                            self.tableView.reloadData()
//                        }
//                }
//            }
//    }
    func isValidGoal(_ goal: GoalCloud, for date: Date) -> Bool {
        // Extract year, month, and day components from the goal's start date
        let goalComponents = Calendar.current.dateComponents([.year, .month, .day], from: goal.startDate)
        
        // Extract year, month, and day components from the selected date
        let selectedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        // Compare the year, month, and day components
        let isValidDate = goalComponents.year == selectedDateComponents.year &&
            goalComponents.month == selectedDateComponents.month &&
            goalComponents.day == selectedDateComponents.day
        
        // Check if a check-in already exists for the selected date
        for checkIn in goal.checkInHistory {
            let checkInComponents = Calendar.current.dateComponents([.year, .month, .day], from: checkIn.dateCompleted)
            if checkInComponents == selectedDateComponents {
                return false // Return false if there is a check-in for the selected date
            }
        }
        
        // Check if the goal's check-in schedule matches the selected date
        switch goal.checkInSchedule {
        case "None":
            return isValidDate
        case "Daily":
            return true
        case "Weekly":
            let daysDifference = Calendar.current.dateComponents([.day], from: goal.startDate, to: date).day ?? 0
            return daysDifference % 7 == 0
        case "Weekdays":
            guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
                return false
            }
            return (2...6).contains(weekday)
        case "Bi-weekly":
            let daysDifference = Calendar.current.dateComponents([.day], from: goal.startDate, to: date).day ?? 0
            return daysDifference % 14 == 0
        case "Monthly":
            return goalComponents.day == selectedDateComponents.day
        case "Quarterly":
            let startQuarter = (goalComponents.month! - 1) / 3
            let selectedQuarter = (selectedDateComponents.month! - 1) / 3
            let totalQuarters = (selectedDateComponents.year! - goalComponents.year!) * 4 + selectedQuarter - startQuarter
            return goalComponents.day == selectedDateComponents.day && totalQuarters % 1 == 0
        case "Yearly":
            return goalComponents.day == selectedDateComponents.day &&
                goalComponents.month == selectedDateComponents.month
        default:
            return isValidDate
        }
    }

  }

extension CheckInIndividualViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add one more row for the date header and one more row for the "Submit Goal" button
        return checkInGoals.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell at indexPath: \(indexPath)")
        
        if indexPath.row == 0 { // Date header cell
            let cell = DateHeaderTableViewCell(style: .default, reuseIdentifier: "dateHeaderCell")
            cell.configure(with: currentDate)
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 { // Submit goal button cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "submitCell")
            cell.textLabel?.text = "Submit Goals"
            cell.textLabel?.textColor = UIColor.white // Set text color to white
            cell.textLabel?.textAlignment = .center // Center the text
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.85) // Set background color to red with opacity 0.85
            cell.layer.cornerRadius = 8.0 // Set corner radius to 8.0
            cell.layer.masksToBounds = true // Clip subviews to bounds
            return cell
        } else { // Goal cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
            let goal = checkInGoals[indexPath.row - 2] // Adjusted index for goals array
            cell.goalLabel.text = goal.checkInQuestion
            
            switch goal.goalType {
            case "Personal":
                cell.viewerImage.image = UIImage(named: "Pen")
            case "Professional":
                cell.viewerImage.image = UIImage(named: "briefcase")
            default:
                cell.viewerImage.image = UIImage(named: "")
            }
            
            cell.statusImage.image = UIImage(named: "Checkbox_")
            cell.indexPath = indexPath // Store the indexPath
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Set the height of the table view cells
        if indexPath.row == 0 { // Date header cell
            return 60
        } else if indexPath.row == 1 { // Submit goal button cell
            return 44
        } else { // Goal cell
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("date cell tapped")
        } else if indexPath.row == 1 { // Submit Goal button tapped
            print("Submit Goals button tapped")
            submitGoals()
        } else {
            print("Status button tapped for indexPath: \(indexPath)")
            if let cell = tableView.cellForRow(at: indexPath) as? RepeatTableViewCell {
                cell.tapCount += 1
                print("Tap count for cell: \(cell.tapCount)")
                switch cell.tapCount % 3 {
                case 0:
                    cell.statusImage.image = UIImage(named: "Checkbox_")
                case 1:
                    cell.statusImage.image = UIImage(named: "Checkbox_A")
                case 2:
                    cell.statusImage.image = UIImage(named: "Checkbox_B")
                default:
                    break
                }
                print(cell.statusImage.image?.description ?? "")
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func submitGoals() {
        guard let currentUser = currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let db = Firestore.firestore()
        var goalsProcessed = 0
        let totalGoals = checkInGoals.count

        for index in 2..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RepeatTableViewCell,
               let imageDescription = cell.statusImage.image?.description {
                if imageDescription.contains("Checkbox_A") || imageDescription.contains("Checkbox_B") {
                    var goalCheckins: [GoalCheckin] = []
                    let goalStatusBox = imageDescription.contains("Checkbox_A")
                    db.collection("users").document(currentUser.uid).collection("goals")
                        .whereField("name", isEqualTo: checkInGoals[index - 2].name)
                        .getDocuments { [self] (querySnapshot, error) in
                            if let error = error {
                                print("Error fetching user goals: \(error.localizedDescription)")
                            } else {
                                guard let documents = querySnapshot?.documents else {
                                    print("No documents found in the 'goals' collection")
                                    return
                                }
                                for document in documents {
                                    let goalId = document.documentID
                                    goalCheckins.append(GoalCheckin(documentID: nil, goalId: goalId, goalName: checkInGoals[index - 2].name, isComplete: goalStatusBox, dateCompleted: Date()))
                                }
                                for checkin in goalCheckins {
                                    addCheckinToFirebase(goalId: checkin.goalId, goalName: checkin.goalName, isComplete: checkin.isComplete, dateCompleted: checkin.dateCompleted, userId: currentUser.uid) { error in
                                        if let error = error {
                                            print("Error adding check-in to Firebase: \(error.localizedDescription)")
                                        } else {
                                            print("Check-in added to Firebase successfully")
                                            FirebaseManager.shared.updateGoals(currentUser: currentUser) { error in
                                                if let error = error {
                                                    print("Error updating goals: \(error.localizedDescription)")
                                                } else {
                                                    print("Goals updated successfully!")
                                                    goalsProcessed += 1
                                                    if goalsProcessed == totalGoals {
                                                        self.loadCheckInGoals(for: self.currentDate)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                } else {
                    goalsProcessed += 1
                    if goalsProcessed == totalGoals {
                        self.loadCheckInGoals(for: self.currentDate)
                    }
                }
            }
        }
    }
}
extension CheckInIndividualViewController: DateHeaderTableViewCellDelegate {
    func didTapPreviousDay() {
        // Update current date to previous day
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
        // Load goals for the new date
        loadCheckInGoals(for: currentDate)
    }

    func didTapReturnToToday() {
        // Update current date to today's date
        currentDate = Date()
        // Load goals for today's date
        tableView.reloadData()
        loadCheckInGoals(for: currentDate)
    }

    func didTapNextDay() {
        // Update current date to next day if it's not beyond today
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
        if tomorrow <= Date() {
            currentDate = tomorrow
            // Load goals for the new date
            loadCheckInGoals(for: currentDate)
        }
    }
}

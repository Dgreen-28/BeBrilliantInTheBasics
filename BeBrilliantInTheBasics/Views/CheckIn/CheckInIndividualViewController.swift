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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    print("Processing goal document: \(document.documentID)")
                    let data = document.data()
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

                    let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: [])

                    // Filter the goals based on startDate
                    if self.isValidGoal(goal, for: date) {
                        self.checkInGoals.append(goal)
                        print("Processing goal document: \(self.checkInGoals)")
                    }
                }

                // Reload table view after fetching and filtering check-in goals
                self.tableView.reloadData()

            }
    }
    func isValidGoal(_ goal: GoalCloud, for date: Date) -> Bool {
        // Extract year, month, and day components from the goal's start date
        let goalComponents = Calendar.current.dateComponents([.year, .month, .day], from: goal.startDate)
        
        // Extract year, month, and day components from the selected date
        let selectedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        // Compare the year, month, and day components
        let isValidDate = goalComponents.year == selectedDateComponents.year &&
            goalComponents.month == selectedDateComponents.month &&
            goalComponents.day == selectedDateComponents.day
        
        
        // Check if the goal's check-in schedule matches the selected date
        switch goal.checkInSchedule {
        case "None":
            // For goals with no specific schedule, return true if the date is valid
            return isValidDate
        case "Daily":
            // For daily goals, return true if the date is valid
            return true
        case "Weekly":
            // For weekly goals, return true if the selected date is within the same week as the goal's start date
            guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: goal.startDate)),
                  let selectedStartOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
                return false
            }
            let daysDifference = Calendar.current.dateComponents([.day], from: startOfWeek, to: selectedStartOfWeek).day ?? 0
            return daysDifference % 7 == 0 // Check if the selected date is exactly 7 days after the start date
            
        case "Weekdays":
            // For goals to be checked in on week days, return true if the selected date is a weekday (Monday to Friday)
            guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
                return false
            }
            return (2...6).contains(weekday) // Monday to Friday are represented by weekday numbers 2 to 6
        case "Bi-weekly":
            // For bi-weekly goals, return true if the selected date is exactly 14 days after the start date
            let daysDifference = Calendar.current.dateComponents([.day], from: goal.startDate, to: date).day ?? 0
            return daysDifference % 14 == 0 // Check if the selected date is exactly 14 days after the start date
        case "Monthly":
            // For monthly goals, return true if the selected date's month and year match the goal's start date
            return goalComponents.year == selectedDateComponents.year && goalComponents.month == selectedDateComponents.month
        case "Quarterly":
            // For quarterly goals, return true if the selected date's quarter and year match the goal's start date
            return goalComponents.year == selectedDateComponents.year &&
                ((goalComponents.month! - 1) / 3) == ((selectedDateComponents.month! - 1) / 3)
        case "Yearly":
            // For yearly goals, return true if the selected date's year matches the goal's start date
            return goalComponents.year == selectedDateComponents.year
        default:
            // For other schedules, return true if the date is valid
            return isValidDate
        }
//        if goal.isComplete == true { return false }
        
        // Check if the goal's start date is in the future compared to the current date
//        if goal.startDate > date {
//            return false
//        }
//        if goal.endDate < date {
//            return false
//        }
//        if goal.isComplete == true || goal.isComplete == false {
//            return false
//        }
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
            cell.statusImage.image = UIImage(named: "Checkbox_")
            // Set initial status button image based on tap count
            //            cell.tapCount = 0
            cell.indexPath = indexPath // Store the indexPath
            
//            cell.tapCount = 2
            cell.statusButton.isHidden = true

            // Define action for status button
            cell.statusBtn = {[unowned self] in
                print("Status button tapped for indexPath: \(indexPath)")
                // Reload table view to reflect changes
                tableView.reloadData()
            }
            
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
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("date cell tapped")
        }
        if indexPath.row == 1 { // Submit Goal button tapped
            print("cell 1 tapped")
            // Loop through the cells beyond cell 1
            guard let currentUser = currentUser else {
                print("Error: Current user is nil.")
                return
            }
            let db = Firestore.firestore()
            for index in 2..<tableView.numberOfRows(inSection: 0) {
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RepeatTableViewCell
                if let imageDescription = cell?.statusImage.image?.description {
                    if imageDescription.contains("Checkbox_A") || imageDescription.contains("Checkbox_B") {
                        // Clear the goalCheckins array for each iteration
                        var goalCheckins: [GoalCheckin] = []
                        // Query Firestore to fetch user's goals based on user ID and goal name
                        var goalStatusBox = true
                        if imageDescription.contains("Checkbox_A") {
                            goalStatusBox = true
                        } else {
                            goalStatusBox = false
                        }
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
                                        // Add completed goal to check-ins array
                                        goalCheckins.append(GoalCheckin(documentID: nil, goalId: goalId, goalName: checkInGoals[index - 2].name, isComplete: goalStatusBox, dateCompleted: Date()))
                                    }
                                    // Loop through goalCheckins to add check-ins to Firebase
                                    for checkin in goalCheckins {
                                        addCheckinToFirebase(goalId: checkin.goalId, goalName: checkin.goalName, isComplete: checkin.isComplete, dateCompleted: checkin.dateCompleted, userId: currentUser.uid) { error in
                                            if let error = error {
                                                print("Error adding check-in to Firebase: \(error.localizedDescription)")
                                            } else {
                                                print("Check-in added to Firebase successfully")
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
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        } else {
            print("Status button tapped for indexPath: \(indexPath)")
            if let cell = tableView.cellForRow(at: indexPath) as? RepeatTableViewCell {
                
                cell.tapCount += 1
                print("Tap count for cell: \(cell.tapCount)")
                // Determine the appropriate image based on the tap count
                 switch cell.tapCount % 3 {
                 case 0:
                     cell.statusImage.image = UIImage(named: "Checkbox_A")
                 case 1:
                     cell.statusImage.image = UIImage(named: "Checkbox_B")
                 case 2:
                     cell.statusImage.image = UIImage(named: "Checkbox_")
                 default:
                     break
                 }
                print(cell.statusImage.image?.description)
            }
            tableView.deselectRow(at: indexPath, animated: true)
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


//    var checkInGoals: [GoalCloud] = [] // Array to store check-in goals
//      var currentDate = Date() // Variable to hold the current date
//
//      override func viewWillAppear(_ animated: Bool) {
//          super.viewWillAppear(animated)
//          loadCheckInGoals(for: currentDate) // Load goals for the current date initially
//      }
//
//      override func viewDidLoad() {
//          super.viewDidLoad()
//          tableView.dataSource = self
//          tableView.delegate = self
//          tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
//          tableView.register(UINib(nibName: "DateHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "dateHeaderCell")
//          tableView.backgroundColor = UIColor.clear
//      }
//
//      func loadCheckInGoals(for date: Date) {
//          print("Loading check-in goals for date: \(date)")
//
//          guard let currentUser = Auth.auth().currentUser else {
//              return
//          }
//
//          let db = Firestore.firestore()
//
//          // Retrieve goals from Firestore for the current user
//          db.collection("users").document(currentUser.uid).collection("goals")
//              .whereField("endDate", isGreaterThanOrEqualTo: date) // Fetch goals with end date greater than or equal to selected date
//              .getDocuments { [weak self] (querySnapshot, error) in
//                  guard let self = self else { return }
//
//                  if let error = error {
//                      print("Error fetching check-in goals: \(error.localizedDescription)")
//                      return
//                  }
//
//                  print("Fetched check-in goals successfully")
//
//                  // Clear the existing checkInGoals array
//                  self.checkInGoals.removeAll()
//
//                  // Iterate through fetched documents and parse them into GoalCloud objects
//                  for document in querySnapshot!.documents {
//                      print("Processing goal document: \(document.documentID)")
//                      let data = document.data()
//                      let name = data["name"] as? String ?? ""
//                      print("name \(name)")
//
//                      let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
//                      print("startadate \(startDate)")
//                      let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
//                      let goalType = data["goalType"] as? String ?? ""
//                      let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
//                      let checkInSchedule = data["checkInSchedule"] as? String ?? ""
//                      let checkInQuestion = data["checkInQuestion"] as? String ?? ""
//                      let isComplete = data["isComplete"] as? Bool
//
//                      let goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: [])
//
//                      // Filter the goals based on startDate
//                      if self.isValidGoal(goal, for: date) {
//                          self.checkInGoals.append(goal)
//                          print("Processing goal document: \(checkInGoals)")
//
//                      }
//                  }
//
//                  // Reload table view after fetching and filtering check-in goals
//                  self.tableView.reloadData()
//                  
//              }
//      }
//
//    func isValidGoal(_ goal: GoalCloud, for date: Date) -> Bool {
//        // Extract year, month, and day components from the goal's start date
//        let goalComponents = Calendar.current.dateComponents([.year, .month, .day], from: goal.startDate)
//        
//        // Extract year, month, and day components from the selected date
//        let selectedDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
//        
//        // Compare the year, month, and day components
//        let isValidDate = goalComponents.year == selectedDateComponents.year &&
//            goalComponents.month == selectedDateComponents.month &&
//            goalComponents.day == selectedDateComponents.day
//        
//        
//        // Check if the goal's start date is in the future compared to the current date
////        if goal.startDate > date {
////            return false
////        }
////        if goal.endDate < date {
////            return false
////        }
////        if goal.isComplete == true || goal.isComplete == false {
////            return false
////        }
//        
//        // Check if the goal's check-in schedule matches the selected date
//        switch goal.checkInSchedule {
//        case "None":
//            // For goals with no specific schedule, return true if the date is valid
//            return isValidDate        
//        case "Daily":
//            // For daily goals, return true if the date is valid
//            return isValidDate
//        case "Weekly":
//            // For weekly goals, return true if the selected date is within the same week as the goal's start date
//            guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: goal.startDate)),
//                  let selectedStartOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
//                return false
//            }
//            let daysDifference = Calendar.current.dateComponents([.day], from: startOfWeek, to: selectedStartOfWeek).day ?? 0
//            return daysDifference % 7 == 0 // Check if the selected date is exactly 7 days after the start date
//            
//        case "Week days":
//            // For goals to be checked in on week days, return true if the selected date is a weekday (Monday to Friday)
//            guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
//                return false
//            }
//            return (2...6).contains(weekday) // Monday to Friday are represented by weekday numbers 2 to 6
//        case "Bi-weekly":
//            // For bi-weekly goals, return true if the selected date is exactly 14 days after the start date
//            let daysDifference = Calendar.current.dateComponents([.day], from: goal.startDate, to: date).day ?? 0
//            return daysDifference % 14 == 0 // Check if the selected date is exactly 14 days after the start date
//        case "Monthly":
//            // For monthly goals, return true if the selected date's month and year match the goal's start date
//            return goalComponents.year == selectedDateComponents.year && goalComponents.month == selectedDateComponents.month
//        case "Quarterly":
//            // For quarterly goals, return true if the selected date's quarter and year match the goal's start date
//            return goalComponents.year == selectedDateComponents.year &&
//                ((goalComponents.month! - 1) / 3) == ((selectedDateComponents.month! - 1) / 3)
//        case "Yearly":
//            // For yearly goals, return true if the selected date's year matches the goal's start date
//            return goalComponents.year == selectedDateComponents.year
//        default:
//            // For other schedules, return true if the date is valid
//            return isValidDate
//        }
//    }
//
//  }
//
//  extension CheckInIndividualViewController: UITableViewDelegate, UITableViewDataSource {
//
//      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//          // Add one more row for the date header
//          return checkInGoals.count + 1
//      }
//
//      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          print("Configuring cell at indexPath: \(indexPath)")
//
//          if indexPath.row == 0 { // Date header cell
//              let cell = DateHeaderTableViewCell(style: .default, reuseIdentifier: "dateHeaderCell")
//              cell.configure(with: currentDate)
//              cell.delegate = self
//              return cell
//          } else { // Goal cell
//              let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
//              let goal = checkInGoals[indexPath.row - 1]
//              cell.goalLabel.text = goal.checkInQuestion
//              if goal.goalType == "Personal"{
//                  cell.viewerImage.image = UIImage(named: "Pen")
//              } else { cell.viewerImage.image = UIImage(named: "briefcase") }
//              cell.statusBtn = {[unowned self] in
//                  let goals = self.checkInGoals[indexPath.row - 1]
//                  cell.statusButton.setImage(UIImage(named: cell.isCheckboxChecked ? "Checkbox_A" : "Checkbox_B"), for: .normal)
//                  print("tapped\(indexPath.row)")
//                  
//              }
//
//              // Configure other UI elements of the cell if needed
//              return cell
//          }
//      }
//
//      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//          // Set the height of the table view cells
//          if indexPath.row == 0 { // Date header cell
//              return 60
//          } else { // Goal cell
//              return 80
//          }
//      }
//
//      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//          // Handle row selection if needed
//          tableView.deselectRow(at: indexPath, animated: true)
//      }
//  }
//
//  extension CheckInIndividualViewController: DateHeaderTableViewCellDelegate {
//      func didTapPreviousDay() {
//          // Update current date to previous day
//          currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
//          // Load goals for the new date
//          loadCheckInGoals(for: currentDate)
//      }
//
//      func didTapReturnToToday() {
//          // Update current date to today's date
//          currentDate = Date()
//          // Load goals for today's date
//          tableView.reloadData()
//          loadCheckInGoals(for: currentDate)
//      }
//
//      func didTapNextDay() {
//          // Update current date to next day if it's not beyond today
//          let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
//          if tomorrow <= Date() {
//              currentDate = tomorrow
//              // Load goals for the new date
//              loadCheckInGoals(for: currentDate)
//          }
//      }
//  }

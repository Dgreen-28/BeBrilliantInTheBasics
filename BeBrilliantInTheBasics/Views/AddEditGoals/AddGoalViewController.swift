//
//  AddGoalViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/4/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class AddGoalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var checkInRepeatPicker: UIPickerView!
    @IBOutlet weak var goalTypePicker: UIPickerView!
    @IBOutlet weak var checkInQTextView: UITextView!
    @IBOutlet weak var addGoalButton: UIButton!
    
    var goal: GoalCloud?
    private var db = Firestore.firestore()

    // Data source for the picker
    var selectedCheckInSchedule: String?
    let checkInRepeatOptions = ["None", "Daily", "Weekly", "Weekdays", "Bi-weekly", "Monthly", "Quarterly", "Yearly"]
    let goalTypeOption = ["Personal", "Professional"]
    var goalPage = ""
        

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        // Set delegates for text view and picker view
        goalTextField.autocapitalizationType = .sentences
        checkInRepeatPicker.dataSource = self
        checkInRepeatPicker.delegate = self
        goalTypePicker.dataSource = self
        goalTypePicker.delegate = self
        print(goalPage)
        print(goal as Any)
        goalTextField.delegate = self
        checkInQTextView.delegate = self
        if goal != nil {
                 // Print goal properties for testing
            print("Goal Name: \(goal!.name)")
            print("Start Date: \(goal!.startDate)")
            print("End Date: \(goal!.endDate)")
            

            guard let currentUser = Auth.auth().currentUser,
                  let goalName = goal?.name else {
                // Handle the case where there's no logged-in user or goal name is missing
                return
            }
            
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
                        // Access timestamp fields and convert them to Date objects
                        if let startDateTimestamp = goalDocument["startDate"] as? Timestamp,
                           let endDateTimestamp = goalDocument["endDate"] as? Timestamp {
                            let startDate = startDateTimestamp.dateValue()
                            let endDate = endDateTimestamp.dateValue()
                            
                            // Assign the dates to the date pickers
                            self.startDatePicker.date = startDate
                            self.endDatePicker.date = endDate
                        }
                    }
                }
                 // Update UI components with goal data
            addGoalButton.setTitle("Update", for: .normal)
            goalTextField.text = goal?.name
            checkInQTextView.text = goal?.checkInQuestion
        }

        
        // Find the index of checkInSchedule in checkInRepeatOptions
        if let index = checkInRepeatOptions.firstIndex(of: goal?.checkInSchedule ?? "Daily") {
            // Select the corresponding row in checkInRepeatPicker
            checkInRepeatPicker.selectRow(index, inComponent: 0, animated: false)
        }
        if let index = goalTypeOption.firstIndex(of: goal?.goalType ?? goalPage) {
            // Select the corresponding row in checkInRepeatPicker
            goalTypePicker.selectRow(index, inComponent: 0, animated: false)
        }
        // Customize button and text view appearance
        addGoalButton.layer.cornerRadius = 8.0
        checkInQTextView.layer.cornerRadius = 8.0
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddGoalTapped(_ sender: Any) {
        
        
        
        //TODO: fix start date bug for if day hasn't come yet
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where there's no logged-in user
            return
        }

        // Gather data from UI
        let name = goalTextField.text ?? ""
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let checkInSchedule = checkInRepeatOptions[checkInRepeatPicker.selectedRow(inComponent: 0)]
        let goalType = goalTypeOption[goalTypePicker.selectedRow(inComponent: 0)]
        let checkInQuestion = checkInQTextView.text ?? ""
        let checkInSuccessRate = 0.0 // You can modify this according to your logic
        let isComplete: Bool? = nil // Initial value, can be nil

        if goal != nil {
            // Update GoalCloud object
            // Ensure that `goal` is not nil and proceed with updating it
            let updatedData: [String: Any] = [
                "name": name,
                "startDate": startDate,
                "endDate": endDate,
                "goalType": goalType,
                "checkInSchedule": checkInSchedule,
                "checkInQuestion": checkInQuestion
                // Add other fields to update as needed
            ]

            let db = Firestore.firestore()

            // Query Firestore to fetch user's goals based on user ID and goal name
            db.collection("users").document(currentUser.uid).collection("goals")
                .whereField("name", isEqualTo: goal!.name)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching user goals: \(error.localizedDescription)")
                    } else {
                        guard let documents = querySnapshot?.documents else {
                            print("No documents found in the 'goals' collection")
                            return
                        }

                        for document in documents {
                            let documentID = document.documentID
                            print("Updating document with ID: \(documentID)")

                            db.collection("users").document(currentUser.uid).collection("goals").document(documentID).updateData(updatedData) { error in
                                if let error = error {
                                    print("Error updating goal with ID \(documentID): \(error.localizedDescription)")
                                } else {
                                    print("Goal with ID \(documentID) updated successfully")
                                    self.navigationController?.popViewController(animated: true)
                                    
                                    self.addFriendAsViewerToGoal(goalID: documentID, friendEmail: "Test28@gmail.com") { error in
                                        if let error = error {
                                            print("Error adding friend as viewer: \(error.localizedDescription)")
                                        } else {
                                            print("Friend added as viewer successfully")
                                        }
                                    }
                                    // Optionally, perform any additional actions after updating each document
                                }
                            }
                        }
                    }
                }
        } else {
            // Create GoalCloud object
            var goal = GoalCloud(name: name, startDate: startDate, endDate: endDate, goalType: goalType, checkInSuccessRate: checkInSuccessRate, checkInSchedule: checkInSchedule, checkInQuestion: checkInQuestion, isComplete: isComplete, checkInHistory: [], viewers: [])

            // Add goal to Firebase
            addGoalToFirebase(goal: &goal, userId: currentUser.uid, viewers: goal.viewers) { error in
                if let error = error {
                    // Handle error
                    print("Error adding goal to Firebase: \(error.localizedDescription)")
                } else {
                    // Goal added successfully
                    print("Goal added successfully")
                    // Optionally, navigate back or perform other actions
                }
            }
            self.navigationController?.popViewController(animated: true)
        }

    }
    // Function to add a single friend as a viewer to a goal
    func addFriendAsViewerToGoal(goalID: String, friendEmail: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(NSError(domain: "Authentication Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
            return
        }

        // Retrieve the user document based on the provided email
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: friendEmail).getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            // Check if user document exists
            guard let document = snapshot?.documents.first else {
                completion(NSError(domain: "User Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found with email: \(friendEmail)"]))
                return
            }

            // Get the UID of the user
            guard let friendUID = document.data()["uid"] as? String else {
                completion(NSError(domain: "UID Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey: "UID not found for user with email: \(friendEmail)"]))
                return
            }

            // Add the user to the viewers list of the goal
            let goalRef = db.collection("users").document(currentUser.uid).collection("goals").document(goalID)
            goalRef.updateData(["viewers.\(friendUID)": true]) { error in
                completion(error)
            }
        }
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                // Return key was pressed, handle return action here
                textView.resignFirstResponder() // Dismiss the keyboard
                // You can perform additional actions here
                return false // Prevent insertion of new line
            }
            return true
        }

}

extension AddGoalViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Number of columns in picker view
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == checkInRepeatPicker {
            return checkInRepeatOptions.count
        } else if pickerView == goalTypePicker {
            return goalTypeOption.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == checkInRepeatPicker {
            return checkInRepeatOptions[row]
        } else if pickerView == goalTypePicker {
            return goalTypeOption[row]
        }
        return nil
    }
}

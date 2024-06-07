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

class AddGoalViewController: UIViewController, AddViewersViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var checkInRepeatPicker: UIPickerView!
    @IBOutlet weak var goalTypePicker: UIPickerView!
    @IBOutlet weak var checkInQTextView: UITextView!
    @IBOutlet weak var addGoalButton: UIButton!
    @IBOutlet weak var addViewersButton: UIButton!
    
    var viewersEdited: Bool = false
    var friendsToAdd: [String] = []
    var goal: GoalCloud?
    private var db = Firestore.firestore()

    // Data source for the picker
    var selectedCheckInSchedule: String?
    let checkInRepeatOptions = ["None", "Daily", "Weekly", "Weekdays", "Bi-weekly", "Monthly", "Quarterly", "Yearly"]
    let goalTypeOption = ["Personal", "Professional"]
    var goalPage = ""
    var goalViewers: [String] = []
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("testtest\(friendsToAdd)")
    }
    
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
        
        
        addViewersButton.layer.cornerRadius = 12.5

        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addViewersTapped(_ sender: Any) {
        print("current: \(friendsToAdd)")
        let addViewersVC = AddViewersViewController()
        addViewersVC.goal = goal
        addViewersVC.delegate = self
        addViewersVC.friendsToAdd = friendsToAdd
        self.navigationController?.pushViewController(addViewersVC, animated: true)
    }
    @IBAction func AddGoalTapped(_ sender: Any) {

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
            let checkInSuccessRate = 0.0 // Modify according to your logic
            let isComplete: Bool? = nil // Initial value, can be nil

            let updatedData: [String: Any] = [
                "name": name,
                "startDate": startDate,
                "endDate": endDate,
                "goalType": goalType,
                "checkInSchedule": checkInSchedule,
                "checkInQuestion": checkInQuestion
            ]

            // Check if goal name is empty
            if name.isEmpty {
                presentAlert(title: "Error", message: "The goal needs a name.")
                return
            }

            // Check if check-in question is empty when check-in schedule is not "none"
            if checkInSchedule != "none" && checkInQuestion.isEmpty {
                presentAlert(title: "Error", message: "You need to provide a check-in question.")
                return
            }

            let db = Firestore.firestore()

            if let goal = goal {
                // Updating an existing goal
                if goal.name == name {
                    // The goal name hasn't changed, proceed with update
                    self.fetchAndUpdateGoals(currentUser: currentUser, goalName: goal.name, updatedData: updatedData)
                } else {
                    // The goal name has changed, check for duplicates
                    db.collection("users").document(currentUser.uid).collection("goals")
                        .whereField("name", isEqualTo: name)
                        .getDocuments { (snapshot, error) in
                            if let error = error {
                                print("Error fetching goals: \(error.localizedDescription)")
                                return
                            }

                            guard let documents = snapshot?.documents else {
                                print("No goal documents found")
                                return
                            }

                            if documents.isEmpty {
                                // No conflict, proceed with goal update
                                self.fetchAndUpdateGoals(currentUser: currentUser, goalName: goal.name, updatedData: updatedData)
                            } else {
                                // Name conflict with an existing goal
                                self.presentDuplicateNameAlert()
                            }
                        }
                }
            } else {
                // Creating a new goal, check for duplicates
                db.collection("users").document(currentUser.uid).collection("goals")
                    .whereField("name", isEqualTo: name)
                    .getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error fetching goals: \(error.localizedDescription)")
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("No goal documents found")
                            return
                        }

                        if documents.isEmpty {
                            // No conflict, proceed with goal creation
                            var newGoal = GoalCloud(
                                name: name,
                                startDate: startDate,
                                endDate: endDate,
                                goalType: goalType,
                                checkInSuccessRate: checkInSuccessRate,
                                checkInSchedule: checkInSchedule,
                                checkInQuestion: checkInQuestion,
                                isComplete: isComplete,
                                checkInHistory: [],
                                viewers: []
                            )

                            addGoalToFirebase(goal: &newGoal, userId: currentUser.uid, viewers: newGoal.viewers) { error in
                                if let error = error {
                                    print("Error adding goal to Firebase: \(error.localizedDescription)")
                                } else {
                                    print("Goal added successfully")
                                    self.fetchAndUpdateGoals(currentUser: currentUser, goalName: newGoal.name, updatedData: updatedData)
                                }
                            }
                        } else {
                            // Name conflict with an existing goal
                            self.presentDuplicateNameAlert()
                        }
                    }
            }
        }

        private func presentAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }

        func fetchAndUpdateGoals(currentUser: User, goalName: String, updatedData: [String: Any]) {
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).collection("goals")
                .whereField("name", isEqualTo: goalName)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching user goals: \(error.localizedDescription)")
                        return
                    }

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
                                if self.viewersEdited {
                                    self.addFriendsAsViewersToGoal(goalID: documentID, friendUIDs: self.friendsToAdd) { error in
                                        if let error = error {
                                            print("Error adding friend as viewer: \(error.localizedDescription)")
                                        } else {
                                            print("Friend added as viewer successfully")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }

        func presentDuplicateNameAlert() {
            let alert = UIAlertController(title: "Duplicate Goal Name", message: "A goal with this name already exists. Please choose a different name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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

    func didUpdateViewers(_ viewers: [String]) {
        self.friendsToAdd = viewers
        print("Updated friends to add: \(self.friendsToAdd)")
    }
    func didEditViewers() {
        self.viewersEdited = true
        print("Viewers edited: \(self.viewersEdited)")
    }
    
    func addFriendsAsViewersToGoal(goalID: String, friendUIDs: [String], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        // Adjust the path to include user ID if goals are stored under each user
        let goalDocumentRef = db.collection("users").document(currentUserID).collection("goals").document(goalID)

        // Retrieve the goal document
        goalDocumentRef.getDocument { (goalSnapshot, goalError) in
            if let goalError = goalError {
                completion(goalError)
                return
            }
            
            guard let goalDocument = goalSnapshot, goalDocument.exists else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Goal document not found"]))
                return
            }
            
//            // Check if the current user is the owner of the goal
//            guard let goalOwnerID = goalDocument.data()?["ownerID"] as? String, goalOwnerID == currentUserID else {
//                // If the current user is not the owner of the goal, return without adding viewers
//                completion(NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "User is not the owner of the goal"]))
//                return
//            }
            
            // Prepare the viewers data
            var viewersData = [String: Bool]()
            for friendUID in friendUIDs {
                viewersData[friendUID] = true
            }
            
            // Update the goal document with the new viewers
            goalDocumentRef.updateData(["viewers": viewersData]) { error in
                if let error = error {
                    print("Error adding viewers to goal: \(error.localizedDescription)")
                    completion(error)
                } else {
                    completion(nil) // Completion after all viewers are added
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return key is pressed
        textField.resignFirstResponder()
        
        // Check if checkInQTextView is empty
        if checkInQTextView.text.isEmpty {
            // Set checkInQTextView's text to goalTextField's text
            checkInQTextView.text = textField.text
        }
        
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

//
//  ManualCheckInViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 6/5/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ManualCheckInViewController: UIViewController {
    
    var goal: GoalCloud?
    var goalTitle: String?
    
    // UI Components
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = .accent
        datePicker.backgroundColor = .secondarySystemBackground
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true // this allows you to change the corner radius
        return datePicker
    }()
    
    private let submitButton = UIButton(type: .system)
    private let checkinToggleButton = UIButton()
    
    // Track toggle button state
    private var isCheckinComplete = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = goalTitle
        self.view.backgroundColor = .white
        
        setupDatePicker()
        setupCheckinToggleButton()
        setupSubmitButton()
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 10 + 60),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCheckinToggleButton() {
        checkinToggleButton.setImage(UIImage(named: "Checkbox_A"), for: .normal)
        checkinToggleButton.translatesAutoresizingMaskIntoConstraints = false
        checkinToggleButton.addTarget(self, action: #selector(toggleCheckinStatus), for: .touchUpInside)
        view.addSubview(checkinToggleButton)
        
        NSLayoutConstraint.activate([
            checkinToggleButton.widthAnchor.constraint(equalToConstant: 35),
            checkinToggleButton.heightAnchor.constraint(equalToConstant: 35),
            checkinToggleButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            checkinToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func toggleCheckinStatus() {
        isCheckinComplete.toggle()
        let imageName = isCheckinComplete ? "Checkbox_A" : "Checkbox_B"
        checkinToggleButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func setupSubmitButton() {
        submitButton.setTitle("Submit Goal", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .red
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitGoal), for: .touchUpInside)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func submitGoal() {
        guard let currentUser = Auth.auth().currentUser, let goal = goal else {
            print("Error: Current user or goal is nil.")
            return
        }

        let db = Firestore.firestore()
        let date = datePicker.date
        let isComplete = self.isCheckinComplete
        
        // Fetch goal by name and then add check-in
        db.collection("users").document(currentUser.uid).collection("goals")
            .whereField("name", isEqualTo: goal.name)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching user goals: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found in the 'goals' collection")
                    return
                }
                
                for document in documents {
                    let goalId = document.documentID
                    let checkinData: [String: Any] = [
                        "goalId": goalId,
                        "goalName": goal.name,
                        "isComplete": isComplete,
                        "dateCompleted": date
                    ]
                    
                    db.collection("users").document(currentUser.uid).collection("goals").document(goalId).collection("checkins")
                        .addDocument(data: checkinData) { error in
                            if let error = error {
                                print("Error adding check-in to Firebase: \(error.localizedDescription)")
                            } else {
                                print("Check-in added to Firebase successfully")
                                self.updateGoalSuccessRate(goalId: goalId, currentUser: currentUser)
                            }
                        }
                }
            }
    }
    
    private func updateGoalSuccessRate(goalId: String, currentUser: User) {
        let db = Firestore.firestore()

        db.collection("users").document(currentUser.uid).collection("goals").document(goalId).collection("checkins").getDocuments { (checkinQuerySnapshot, checkinError) in
            if let checkinError = checkinError {
                print("Error fetching check-ins for goal \(goalId): \(checkinError.localizedDescription)")
                return
            } else {
                guard let checkinDocuments = checkinQuerySnapshot?.documents else {
                    print("No check-ins found for goal \(goalId)")
                    return
                }

                var totalCheckins = 0
                var successfulCheckins = 0

                for checkinDocument in checkinDocuments {
                    let isComplete = checkinDocument.get("isComplete") as? Bool ?? false
                    totalCheckins += 1
                    if isComplete {
                        successfulCheckins += 1
                    }
                }

                let checkInSuccessRate = totalCheckins > 0 ? Double(successfulCheckins) / Double(totalCheckins) * 100.0 : 0.0

                db.collection("users").document(currentUser.uid).collection("goals").document(goalId).updateData(["checkInSuccessRate": checkInSuccessRate]) { error in
                    if let error = error {
                        print("Error updating checkInSuccessRate for goal \(goalId): \(error.localizedDescription)")
                    } else {
                        print("checkInSuccessRate updated successfully for goal \(goalId)")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}

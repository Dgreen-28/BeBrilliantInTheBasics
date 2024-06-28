//
//  FirebaseData.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

var fbComplete: Bool?

struct GoalCheckin {
    var documentID: String? // Add documentID property
    let goalId: String
    let goalName: String
    let isComplete: Bool
    let dateCompleted: Date
}
struct GoalCloud {
    var documentID: String? // Add documentID property
    let name: String
    let startDate: Date
    let endDate: Date
    let goalType: String
    var checkInSuccessRate: Double
    let checkInSchedule: String
    let checkInQuestion: String
    var isComplete: String // Optional, as it can be nil initially
    var checkInHistory: [GoalCheckin] // Array to store check-in history
    var viewers: [String] // Array to store friend IDs who are viewers of the goal
    var ownerName: String? // Add this property
    var ownerUID: String? // New property to hold the owner's UID
}

struct Friend {
    let email: String
    let uid: String
    let username: String
    var isViewer: Bool
}


//struct GoalCloud {
//    var documentID: String? // Add documentID property
//    let name: String
//    let startDate: Date
//    let endDate: Date
//    let goalType: String
//    let checkInSuccessRate: Double
//    let checkInSchedule: String
//    let checkInQuestion: String
//    var isComplete: Bool? // Optional, as it can be nil initially
//    var checkInHistory: [GoalCheckin] // Array to store check-in history
//}

func addGoalToFirebase(goal: inout GoalCloud, userId: String, viewers: [String], completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    var data: [String: Any] = [
        "name": goal.name,
        "startDate": goal.startDate,
        "endDate": goal.endDate,
        "goalType": goal.goalType,
        "checkInSuccessRate": goal.checkInSuccessRate,
        "checkInSchedule": goal.checkInSchedule,
        "checkInQuestion": goal.checkInQuestion,
        "isComplete": goal.isComplete,
        "viewers": viewers // Add viewers to data
    ]

    // Convert Date objects to Timestamp
    let startDateTimestamp = Timestamp(date: goal.startDate)
    let endDateTimestamp = Timestamp(date: goal.endDate)
    
    data["startDate"] = startDateTimestamp
    data["endDate"] = endDateTimestamp

    db.collection("users").document(userId).collection("goals").addDocument(data: data) { error in
        if let error = error {
            completion(error)
        } else {
            completion(nil) // Success
        }
    }
}


private func updateGoalCompletionStatus(goalId: String, isComplete: Bool, completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    guard let currentUser = Auth.auth().currentUser else {
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        completion(error)
        return
    }

    let goalRef = db.collection("users").document(currentUser.uid).collection("goals").document(goalId)
    goalRef.updateData([
        "isComplete": isComplete,
        "doneGoal": isComplete
    ]) { error in
        completion(error)
    }
}

func addCheckinToFirebase(goalId: String, goalName: String, isComplete: Bool, dateCompleted: Date, userId: String, completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    let data: [String: Any] = [
        "goalId": goalId,
        "goalName": goalName,
        "isComplete": isComplete,
        "dateCompleted": dateCompleted
    ]

    db.collection("users").document(userId).collection("goals").document(goalId).collection("checkins").addDocument(data: data) { error in
        if let error = error {
            completion(error)
        } else {
            completion(nil) // Success
        }
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

func updateGoalInFirebase(goalId: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("goals").document(goalId).updateData(updatedData) { error in
        if let error = error {
            completion(error)
        } else {
            completion(nil)
        }
    }
}



class FirebaseManager {
    static let shared = FirebaseManager() // Singleton instance
    
    private init() {} // Private initializer for singleton
    
    func updateGoals(currentUser: User?, completion: @escaping (Error?) -> Void) {
        guard let currentUser = currentUser else {
            print("Error: Current user is nil.")
            completion(NSError(domain: "YourAppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user is nil"]))
            return
        }
        
        let db = Firestore.firestore()

        // Query Firestore to fetch user's goals based on user ID
        db.collection("users").document(currentUser.uid).collection("goals").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user goals: \(error.localizedDescription)")
                completion(error)
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents found in the 'goals' collection")
                    completion(nil)
                    return
                }

                for document in documents {
                    let documentID = document.documentID

                    // Query Firestore to fetch check-ins for the current goal
                    db.collection("users").document(currentUser.uid).collection("goals").document(documentID).collection("checkins").getDocuments { (checkinQuerySnapshot, checkinError) in
                        if let checkinError = checkinError {
                            print("Error fetching check-ins for goal \(documentID): \(checkinError.localizedDescription)")
                            completion(checkinError)
                        } else {
                            guard let checkinDocuments = checkinQuerySnapshot?.documents else {
                                print("No check-ins found for goal \(documentID)")
                                completion(nil)
                                return
                            }

                            var totalCheckins = 0
                            var successfulCheckins = 0

                            // Count the number of check-ins and successful check-ins
                            for checkinDocument in checkinDocuments {
                                let isComplete = checkinDocument.get("isComplete") as? Bool ?? false
                                totalCheckins += 1
                                if isComplete {
                                    successfulCheckins += 1
                                }
                            }

                            // Calculate checkInSuccessRate
                            let checkInSuccessRate = totalCheckins > 0 ? Double(successfulCheckins) / Double(totalCheckins) * 100.0 : 0.0

                            print("For goal \(documentID):")
                            print("Total check-ins: \(totalCheckins)")
                            print("Successful check-ins: \(successfulCheckins)")
                            print("Check-in success rate: \(checkInSuccessRate)%")

                            // Update the checkInSuccessRate for the current goal
                            db.collection("users").document(currentUser.uid).collection("goals").document(documentID).updateData(["checkInSuccessRate": checkInSuccessRate]) { error in
                                if let error = error {
                                    print("Error updating checkInSuccessRate for goal \(documentID): \(error.localizedDescription)")
                                    completion(error)
                                } else {
                                    print("checkInSuccessRate updated successfully for goal \(documentID)")
                                    // Optionally, perform any additional actions after updating checkInSuccessRate
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



//origial
//
//func addGoalToFirebase(goal: GoalCloud, userId: String, completion: @escaping (Error?) -> Void) {
//    let db = Firestore.firestore()
//    var data: [String: Any] = [
//        "name": goal.name,
//        "startDate": goal.startDate,
//        "endDate": goal.endDate,
//        "goalType": goal.goalType,
//        "checkInSuccessRate": goal.checkInSuccessRate,
//        "checkInSchedule": goal.checkInSchedule,
//        "checkInQuestion": goal.checkInQuestion
//    ]
//    if let isComplete = goal.isComplete {
//        data["isComplete"] = isComplete
//    }
//
//    // Add the goal document to the user's "goals" subcollection
//    db.collection("users").document(userId).collection("goals").addDocument(data: data) { error in
//        if let error = error {
//            completion(error)
//        } else {
//            completion(nil) // Success
//        }
//    }
//}
//possible replace
//func addGoalToFirebase(goal: GoalCloud, completion: @escaping (Error?) -> Void) {
//    let db = Firestore.firestore()
//    var data: [String: Any] = [
//        "name": goal.name,
//        "startDate": goal.startDate,
//        "endDate": goal.endDate,
//        "goalType": goal.goalType,
//        "checkInSuccessRate": goal.checkInSuccessRate,
//        "checkInSchedule": goal.checkInSchedule,
//        "checkInQuestion": goal.checkInQuestion
//    ]
//    if let isComplete = goal.isComplete {
//        data["isComplete"] = isComplete
//    }
//    
//    // Add the goal document to a collection accessible to all users
//    db.collection("shared_goals").addDocument(data: data) { error in
//        if let error = error {
//            completion(error)
//        } else {
//            completion(nil) // Success
//        }
//    }
//}

/*User -> email -> goal(collection) -> so on
func addGoalToFirebase(goal: GoalCloud, userEmail: String, completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    var data: [String: Any] = [
        "name": goal.name,
        "startDate": goal.startDate,
        "endDate": goal.endDate,
        "goalType": goal.goalType,
        "checkInSuccessRate": goal.checkInSuccessRate,
        "checkInSchedule": goal.checkInSchedule,
        "checkInQuestion": goal.checkInQuestion
    ]
    if let isComplete = goal.isComplete {
        data["isComplete"] = isComplete
    }

    // Add the goal document to the user's "goals" subcollection
    db.collection("users").document(userEmail).collection("goals").addDocument(data: data) { (error) in
        if let error = error {
            completion(error)
        } else {
            completion(nil) // Success
        }
    }
*/

//
//class FirebaseData {
//    
//    // Function to create a new goal
//    static func createGoal(userId: String, goalData: [String: Any], completion: @escaping (Error?) -> Void) {
//        let db = Firestore.firestore()
//        
//        // Add the goal to the goals collection
//        db.collection("goals").document(userId).addDocument(data: goalData) { error in
//            completion(error)
//        }
//    }
//    
//    // Function to fetch goals for a user
//    static func fetchGoals(userId: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
//        let db = Firestore.firestore()
//        
//        // Fetch goals for the user
//        db.collection("goals").document(userId).getDocument { snapshot, error in
//            if let error = error {
//                completion(nil, error)
//            } else {
//                let goals = snapshot?.documents ?? []
//                completion(goals, nil)
//            }
//        }
//    }
//    
//    // Function to update check-in status for a goal
//    static func updateCheckInStatus(userId: String, goalId: String, checkInData: [String: Any], completion: @escaping (Error?) -> Void) {
//        let db = Firestore.firestore()
//        
//        // Update the check-in status for the goal
//        db.collection("goals").document(userId).collection(goalId).document("checkInStatus").updateData(checkInData) { error in
//            completion(error)
//        }
//    }
//    
//    // Example usage
//    static func exampleUsage() {
//        let goalData: [String: Any] = [
//            "name": "Call Parents Weekly",
//            "startDate": Timestamp(...),
//            "endDate": Timestamp(...),
//            "schedule": "weekly",
//            "checkInQuestion": "Did you call your parents this week?",
//            "participants": [
//                "viewerId1": true,
//                "adminId1": true
//            ],
//            "checkInStatus": [
//                "lastCheckInDate": Timestamp(...),
//                "totalCheckIns": 10,
//                "completedCheckIns": 8,
//                "checkInPercentage": 80  // Check-in percentage
//            ]
//        ]
//        
//        createGoal(userId: "123", goalData: goalData) { error in
//            if let error = error {
//                // Handle error
//                print("Error creating goal: \(error.localizedDescription)")
//            } else {
//                // Goal created successfully
//                print("Goal created successfully!")
//            }
//        }
//        
//        fetchGoals(userId: "123") { goals, error in
//            if let error = error {
//                // Handle error
//                print("Error fetching goals: \(error.localizedDescription)")
//            } else {
//                // Process fetched goals
//                for goal in goals {
//                    print("Goal: \(goal.data())")
//                }
//            }
//        }
//        
//        let checkInData: [String: Any] = [
//            "lastCheckInDate": Timestamp(...),
//            "totalCheckIns": 10,
//            "completedCheckIns": 8
//        ]
//        
//        updateCheckInStatus(userId: "123", goalId: "456", checkInData: checkInData) { error in
//            if let error = error {
//                // Handle error
//                print("Error updating check-in status: \(error.localizedDescription)")
//            } else {
//                // Check-in status updated successfully
//                print("Check-in status updated successfully!")
//            }
//        }
//    }
//}

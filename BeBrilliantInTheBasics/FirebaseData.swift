//
//  FirebaseData.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/29/24.
//

import Foundation
//import FirebaseFirestore
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

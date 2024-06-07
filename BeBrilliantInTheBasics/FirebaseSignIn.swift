//
//  FirebaseSignIn.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/27/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseSignIn {

//    static func createAccount(email: String, password: String, completion: @escaping (Error?) -> Void) {
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//            if let error = error {
//                // Handle error
//                completion(error)
//            } else {
//                // Account creation successful
//                saveAuthenticationState()
//                checkAuthenticationState()
//                
//                // Create a corresponding document in Firestore
//                let db = Firestore.firestore()
//                let userId = authResult?.user.uid ?? ""
//                db.collection("users").document(userId).setData(["email": email, "uid": userId]) { error in
//                    if let error = error {
//                        // Handle Firestore error
//                        completion(error)
//                    } else {
//                        // Firestore document creation successful
//                        completion(nil)
//                    }
//                }
//            }
//        }
//    }
//    

    func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // Email login
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                // Login successful, save authentication state and check it
                FirebaseSignIn.saveAuthenticationState()
                FirebaseSignIn.checkAuthenticationState()
                completion(true)
            }
        } else if let username = username {
            // Username login (assuming username is the email address here)
            Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                // Login successful, save authentication state and check it
                FirebaseSignIn.saveAuthenticationState()
                FirebaseSignIn.checkAuthenticationState()
                completion(true)
            }
        }
    }

    static func createAccount(email: String, username: String, password: String, confirmPassword: String, completion: @escaping (Error?) -> Void) {
        print("Attempting to create account...")
        
        // Check if passwords match
        guard password == confirmPassword else {
            print("Passwords do not match.")
            completion(NSError(domain: "com.yourapp.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"]))
            return
        }
        
        print("Passwords match.")
        
        // Create user with email and password
        
        // After creating the user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, createUserError) in
            if let createUserError = createUserError {
                // Handle error
                print("Error creating user:", createUserError.localizedDescription)
                completion(createUserError)
            } else {
                // Account creation successful
                print("Account created successfully for email:", email)
                
                // Store additional user data in Firestore
                let userData = [
                    "uid": authResult!.user.uid,
                    "username": username,
                    "email": email,
                    // Add more fields as needed
                ]
                
                // Reference to the Firestore database
                let db = Firestore.firestore()
                
                // Add the user data to Firestore under a 'users' collection
                db.collection("users").document(authResult!.user.uid).setData(userData) { error in
                    if let error = error {
                        // Handle error
                        print("Error writing user data to Firestore:", error.localizedDescription)
                        completion(error)
                    } else {
                        // Data successfully written to Firestore
                        print("User data written to Firestore")
                        completion(nil)
                    }
                }
            }
        }

    }

    static func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let signOutError as NSError {
            completion(signOutError)
        }
    }

    private static func saveAuthenticationState() {
        // For simplicity, let's assume authToken is a token obtained after successful sign-in
        let authToken = "exampleAuthToken"
        UserDefaults.standard.set(authToken, forKey: "AuthToken")
    }

    static func checkAuthenticationState() {
        if let authToken = UserDefaults.standard.string(forKey: "AuthToken") {
            // User is signed in, proceed to the main screen or wherever appropriate
            print("User is signed in with token: \(authToken)")
            // Proceed to the main screen
        } else {
            // User is not signed in, navigate to the sign-in screen or perform other actions
            print("User is not signed in")
            // Navigate to the sign-in screen
        }
    }
}


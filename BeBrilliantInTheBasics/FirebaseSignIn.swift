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

    static func createAccount(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                // Handle error
                completion(error)
            } else {
                // Account creation successful
                saveAuthenticationState()
                checkAuthenticationState()
                
                // Create a corresponding document in Firestore
                let db = Firestore.firestore()
                let userId = authResult?.user.uid ?? ""
                db.collection("users").document(userId).setData(["email": email]) { error in
                    if let error = error {
                        // Handle Firestore error
                        completion(error)
                    } else {
                        // Firestore document creation successful
                        completion(nil)
                    }
                }
            }
        }
    }
/*
 static func createAccount(email: String, username: String, password: String, completion: @escaping (Error?) -> Void) {
     // Check if email or username has already been used
     Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
         if let error = error {
             // Handle error
             completion(error)
         } else if let providers = providers, !providers.isEmpty {
             // Email is already in use
             let emailInUseError = NSError(domain: "YourAppDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email is already in use."])
             completion(emailInUseError)
         } else {
             // Check if username has already been used
             let db = Firestore.firestore()
             db.collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
                 if let error = error {
                     // Handle Firestore error
                     completion(error)
                 } else if let snapshot = snapshot, !snapshot.isEmpty {
                     // Username is already in use
                     let usernameInUseError = NSError(domain: "YourAppDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username is already in use."])
                     completion(usernameInUseError)
                 } else {
                     // Neither email nor username is in use, proceed with account creation
                     Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                         if let error = error {
                             // Handle error
                             completion(error)
                         } else if let authResult = authResult {
                             // Account creation successful
                             saveAuthenticationState()
                             checkAuthenticationState()
                             
                             // Create a corresponding document in Firestore
                             let userId = authResult.user.uid
                             db.collection("users").document(userId).setData(["email": email, "username": username]) { error in
                                 if let error = error {
                                     // Handle Firestore error
                                     completion(error)
                                 } else {
                                     // Firestore document creation successful
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
*/
/* static func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
 Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
     if let error = error {
         // Handle error
         completion(nil, error)
     } else if let authResult = authResult {
         // Sign in successful
         completion(authResult, nil)
     }
 }
}
*/
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


//private func checkAuthenticationState() {
//    if let authToken = UserDefaults.standard.string(forKey: "AuthToken") {
//        // User is signed in, proceed to the main screen or wherever appropriate
//        print("User is signed in with token: \(authToken)")
//        // Proceed to the main screen
//    } else {
//        // User is not signed in, navigate to the sign-in screen or perform other actions
//        print("User is not signed in")
//        // Navigate to the sign-in screen
//    }
//}

//@IBAction func signUpButtonTapped(_ sender: UIButton) {
//    // Perform validation on email and password fields
//    guard let email = emailTextField.text, !email.isEmpty,
//          let password = passwordTextField.text, !password.isEmpty else {
//        // Show error message to the user if fields are empty
//        return
//    }
//
//    // Call the createAccount function
//    createAccount(email: email, password: password) { error in
//        if let error = error {
//            // Handle error (e.g., show error message to user)
//            print("Error creating account: \(error.localizedDescription)")
//        } else {
//            // Account creation successful, proceed with next steps (e.g., navigate to next screen)
//            print("Account created successfully")
//        }
//    }
//}

//@IBAction func signOutButtonTapped(_ sender: UIButton) {
//    // Call the signOut function
//    signOut { error in
//        if let error = error {
//            // Handle error (e.g., show error message to user)
//            print("Error signing out: \(error.localizedDescription)")
//        } else {
//            // Sign out successful, proceed with next steps (e.g., navigate to sign-in screen)
//            print("Sign out successful")
//            // Navigate to sign-in screen or perform any other necessary action
//        }
//    }
//}

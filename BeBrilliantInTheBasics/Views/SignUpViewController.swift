//
//  SignUpViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 4/3/24.
//

import UIKit
import FirebaseFirestore

class SignUpViewController:  UIViewController, UITextFieldDelegate {
    
    // Declare email, username, and password text fields as properties
    private var emailTextField: UITextField!
    private var usernameTextField: UITextField!
    private var passwordTextField: UITextField!
    private var reEnterPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupSignUpButton()
        setupTextFields()
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        reEnterPasswordTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    private func setupBackground() {
        // Determine the background image based on device type
        let backgroundImageName: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundImageName = "AddGoalsBG_iPad"
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            backgroundImageName = "Add Goals"
        } else {
            backgroundImageName = "Add Goals"
        }
        
        // Add background image view covering the entire view
        let backgroundImageView = UIImageView(image: UIImage(named: backgroundImageName))
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.frame = view.bounds
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        // Apply red theme to the view
        view.backgroundColor = UIColor.red
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 { // Check if this is the username text field
            // Convert the replacement string to lowercase
            let lowercaseString = string.lowercased()
            
            // Get the current text
            if let text = textField.text as NSString? {
                let updatedText = text.replacingCharacters(in: range, with: lowercaseString)
                textField.text = updatedText
                return false
            }
        }
        return true
    }

    private func setupSignUpButton() {
        // Add sign up button
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = .black
        signUpButton.layer.cornerRadius = 8
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        // Position the sign up button
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpButton.widthAnchor.constraint(equalToConstant: 200),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    func presentAlert(with message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func signUpButtonTapped() {
        // Perform validation on email and password fields
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = reEnterPasswordTextField.text, !confirmPassword.isEmpty,
              let username = usernameTextField.text, !username.isEmpty else {
            // Show error message to the user if fields are empty
            print("Please fill in all fields.")
            presentAlert(with: "Please fill in all fields.")
            return
        }
        // Check if passwords match
        if passwordTextField.text != reEnterPasswordTextField.text {
            print("Passwords don't match.")
            presentAlert(with: "Passwords don't match.")
            return
        }

        let db = Firestore.firestore()
        
        // Check if email is already in use
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking email:", error.localizedDescription)
                self.presentAlert(with: "Error checking email: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                print("Email is already in use.")
                self.presentAlert(with: "Email is already in use.")
                return
            }

            // Check if username is already in use
            db.collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking username:", error.localizedDescription)
                    self.presentAlert(with: "Error checking username: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Username is already in use.")
                    self.presentAlert(with: "Username is already in use.")
                    return
                }

                // If both email and username are not in use, proceed to create account
                FirebaseSignIn.createAccount(email: email, username: username, password: password, confirmPassword: confirmPassword) { error in
                    if let error = error {
                        // Handle error
                        print("Error creating account:", error.localizedDescription)
                        self.presentAlert(with: "Error creating account: \(error.localizedDescription)")
                    } else {
                        // Account created successfully
                        print("Account created successfully")
            
                        let alertController = UIAlertController(title: "Account creted", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                            // Dismiss the current view controller when OK is tapped
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }

    private func setupTextFields() {
        // Add sign-up label
        let signUpLabel = UILabel()
        signUpLabel.text = "Sign Up"
        signUpLabel.font = UIFont.boldSystemFont(ofSize: 24)
        signUpLabel.textColor = .black
        view.addSubview(signUpLabel)
        
        // Position the sign-up label
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signUpLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Add email text field
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.backgroundColor = .white
        emailTextField.layer.cornerRadius = 8
        let eleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: emailTextField.frame.height)) // left padding to the textfield
        emailTextField.leftView = eleftView
        emailTextField.leftViewMode = .always
        emailTextField.autocapitalizationType = .none // Disable autocapitalization
        view.addSubview(emailTextField)
        
        // Add username text field
        usernameTextField = UITextField()
        usernameTextField.placeholder = "Username"
        usernameTextField.backgroundColor = .white
        usernameTextField.layer.cornerRadius = 8
        let uleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: usernameTextField.frame.height)) // left padding to the textfield
        usernameTextField.leftView = uleftView
        usernameTextField.leftViewMode = .always
        usernameTextField.autocapitalizationType = .none // Disable autocapitalization
        usernameTextField.delegate = self
        usernameTextField.tag = 1 // Assign a unique tag to this text field
        view.addSubview(usernameTextField)
        
        // Add password text field
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = .white
        passwordTextField.layer.cornerRadius = 8
        let pleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: passwordTextField.frame.height)) // left padding to the textfield
        passwordTextField.leftView = pleftView
        passwordTextField.leftViewMode = .always
        passwordTextField.autocapitalizationType = .none // Disable autocapitalization
        passwordTextField.isSecureTextEntry = true // Hide characters
        view.addSubview(passwordTextField)
        
        // Add re-enter password text field
        reEnterPasswordTextField = UITextField()
        reEnterPasswordTextField.placeholder = "Re-enter Password"
        reEnterPasswordTextField.backgroundColor = .white
        reEnterPasswordTextField.layer.cornerRadius = 8
        let rleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: reEnterPasswordTextField.frame.height)) // left padding to the textfield
        reEnterPasswordTextField.leftView = rleftView
        reEnterPasswordTextField.leftViewMode = .always
        reEnterPasswordTextField.autocapitalizationType = .none // Disable autocapitalization
        reEnterPasswordTextField.isSecureTextEntry = true // Hide characters
        view.addSubview(reEnterPasswordTextField)

        
        // Position the text fields
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            reEnterPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            reEnterPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reEnterPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reEnterPasswordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

}

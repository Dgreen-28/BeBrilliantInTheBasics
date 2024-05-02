//
//  SignInViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/26/24.
//
import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    // Declare email and password text fields as properties
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLoginButton()
        setupTextFields()
        setupCreateAccountButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupBackground() {
        // Add background image view covering the entire view
        let backgroundImageView = UIImageView(image: UIImage(named: "Add Goals"))
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
    
    private func setupLoginButton() {
        // Add login button
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .black
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Position the login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loginButtonTapped() {
        // Perform validation on email and password fields
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show error message to the user if fields are empty
            return
        }

        // Call the createAccount function from FirebaseSignIn
        FirebaseSignIn.createAccount(email: email, password: password) { error in
            if let error = error {
                // Handle error (e.g., show error message to user)
                print("Error creating account: \(error.localizedDescription)")
            } else {
                // Account creation successful, proceed with next steps (e.g., navigate to next screen)
                print("Account created successfully")
                self.dismiss(animated: true, completion: nil)
            }
        }
//        // Perform validation on email and password fields
//        guard let email = emailTextField.text, !email.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            // Show error message to the user if fields are empty
//            return
//        }
//
//        // Call the createAccount function
//        createAccount(email: email, password: password) { error in
//            if let error = error {
//                // Handle error (e.g., show error message to user)
//                print("Error creating account: \(error.localizedDescription)")
//                print(self.emailTextField.text!)
//                print(self.passwordTextField.text!)
//            } else {
//                // Account creation successful, proceed with next steps (e.g., navigate to next screen)
//                print("Account created successfully")
//                self.dismiss(animated: true, completion: nil)
//
//            }
//        }
//        
        //TODO: Remove
//        dismiss(animated: true, completion: nil)

    }
    
    private func setupTextFields() {
        // Add email text field
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.backgroundColor = .white
        emailTextField.layer.cornerRadius = 8
        let eleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: emailTextField.frame.height)) // left padding to the textfield
        emailTextField.leftView = eleftView
        emailTextField.leftViewMode = .always
        view.addSubview(emailTextField)
        
        // Add password text field
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = .white
        passwordTextField.layer.cornerRadius = 8
        let pleftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: passwordTextField.frame.height)) // left padding to the textfield
        passwordTextField.leftView = pleftView
        passwordTextField.leftViewMode = .always
        view.addSubview(passwordTextField)
        
        // Position the text fields
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCreateAccountButton() {
        // Add create account button
        let createAccountButton = UIButton(type: .system)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.backgroundColor = .black
        createAccountButton.layer.cornerRadius = 8
        view.addSubview(createAccountButton)
        
        // Position the create account button
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            createAccountButton.widthAnchor.constraint(equalToConstant: 200),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

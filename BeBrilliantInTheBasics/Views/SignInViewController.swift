//
//  SignInViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/26/24.
//
import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {

    // Declare email and password text fields as properties
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    private var createAccountButton: UIButton!
    private var forgotPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTextFields()
        setupLoginButton()
        setupCreateAccountButton()
        setupForgotPasswordButton()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
    
    private func setupLoginButton() {
        // Add login button
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .black
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Position the login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
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
        emailTextField.autocapitalizationType = .none // Disable autocapitalization
        view.addSubview(emailTextField)
        
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
        
        // Position the text fields
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCreateAccountButton() {
        // Add create account button
        createAccountButton = UIButton(type: .system)
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.backgroundColor = .black
        createAccountButton.layer.cornerRadius = 8
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        view.addSubview(createAccountButton)
        
        // Position the create account button
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupForgotPasswordButton() {
        // Add forgot password button
        forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.black, for: .normal)
        forgotPasswordButton.backgroundColor = .clear
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        view.addSubview(forgotPasswordButton)
        
        // Position the forgot password button
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Calculate the new center for emailTextField
        let horizontalCenterY = view.bounds.height / 2
        let emailTextFieldCenterY = horizontalCenterY - 100
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.topAnchor, constant: emailTextFieldCenterY),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 10),
            createAccountButton.widthAnchor.constraint(equalToConstant: 200),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func createAccountTapped() {
        let signUpVC = SignUpViewController() // Assuming SignUpViewController is programmatically created
        let navController = UINavigationController(rootViewController: signUpVC)
        signUpVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSignUp))
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        print("Create account tapped")
    }
    
    @objc private func cancelSignUp() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func loginButtonTapped() {
        // Perform validation on email and password fields
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show error message to the user if fields are empty
            presentAlert(title: "Error", message: "Email and password fields cannot be empty.")
            return
        }

        // Call the loginUser function from FirebaseSignIn
        let firebaseSignIn = FirebaseSignIn()
        firebaseSignIn.loginUser(username: nil, email: email, password: password) { success in
            if success {
                // Login successful, proceed with next steps (e.g., navigate to next screen)
                print("Login successful")
                self.dismiss(animated: true, completion: nil)
            } else {
                // Login failed, handle error (e.g., show error message to user)
                print("Login failed")
                self.presentAlert(title: "Error", message: "Wrong Email or Password")
            }
        }
    }
    
    @objc private func forgotPasswordTapped() {
        let alertController = UIAlertController(title: "Forgot Password", message: "Enter your email to reset your password.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
            guard let email = alertController.textFields?.first?.text, !email.isEmpty else {
                self.presentAlert(title: "Error", message: "Email field cannot be empty.")
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self.presentAlert(title: "Success", message: "Password reset email sent.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

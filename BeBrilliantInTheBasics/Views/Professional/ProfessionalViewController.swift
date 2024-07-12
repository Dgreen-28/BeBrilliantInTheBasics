//
//  ProfessionalViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/18/24.
//

import GoogleMobileAds
import Foundation
import UIKit
import FirebaseAuth
import AppTrackingTransparency
import AdSupport

class ProfessionalViewController: UIViewController, GADBannerViewDelegate {

    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var professionalSegmentedCotrol: UISegmentedControl!
    @IBOutlet weak var addGoalButton: UIButton!
    @IBOutlet weak var notebookImage: UIImageView!
    
    private var professionalPageViewController: ProfessionalPageViewController?
    private var destiny: ProfessionalPageViewController?
    
    private let banner: GADBannerView = {
        let banner = GADBannerView()
        banner.adUnitID = "ca-app-pub-3709637295446963/5328997383"
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner }()

    func requestIDFA() {
    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            break
        default:
            break
        }
     })
   }
    
    var indexOfCurrentModel:Int?
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        loadHelp()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Determine the background image based on device type
        let backgroundImageName: String
          if UIDevice.current.userInterfaceIdiom == .pad {
              backgroundImageName = "PROFESSIONAL2"
          } else {
              backgroundImageName = "PROFESSIONAL1"
          }

          // Debug statement to check which image is being selected
          print("Selected background image name: \(backgroundImageName)")

          // Set the background image
          if let backgroundImage = UIImage(named: backgroundImageName) {
              notebookImage.image = backgroundImage
              notebookImage.contentMode = .scaleToFill
          } else {
              print("Image not found: \(backgroundImageName)")
          }
//        let backgroundImageName: String
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                backgroundImageName = "PROFESSIONAL2"
//            } else if UIDevice.current.userInterfaceIdiom == .phone {
//                backgroundImageName = "PROFESSIONAL1"
//            } else {
//                backgroundImageName = "PROFESSIONAL1"
//            }
//        notebookImage.image = UIImage(named: backgroundImageName)

        // Set separator insets programmatically
        checkAuthenticationState()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didGetNotification(_:)),
                                               name: NSNotification.Name("text"),
                                               object: nil)
        requestIDFA()

        banner.rootViewController = self
        view.addSubview(banner)
        banner.delegate = self

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        banner.frame = CGRect(x: 10,
//                              y: view.safeAreaInsets.top + 10,
//                              width: view.frame.size.width - 20,
//                              height: 35).integral
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let destination = segue.destination as? ProfessionalPageViewController
        {
            destiny = destination
        }
    }
    @IBAction func personalSegmentToggled(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            destiny?.goto(index: 0)
        case 1:
            destiny?.goto(index: 1)
        default:
            break
        }
    }
    
    // Check authentication state
    private func checkAuthenticationState() {
        if let _ = Auth.auth().currentUser {
            // User is signed in, continue with the regular flow
            print("User is signed in")
        } else {
            // User is not signed in, present SignInViewController modally
            let signInVC = SignInViewController()
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        let infopageVC = InfoPageViewController()
        infopageVC.infoText = "professional Page" // Pass the appropriate case identifier
        infopageVC.modalPresentationStyle = .overCurrentContext
        infopageVC.modalPresentationStyle = .overFullScreen // This will ensure the modal covers the whole screen
        infopageVC.modalTransitionStyle = .crossDissolve // Optional: for a fade transition
        present(infopageVC, animated: true, completion: nil)
    }
    @IBAction func addGoalTapped(_ sender: Any) {
        let addVC = storyboard?.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController
        addVC!.goalPage = "Professional"
        navigationController?.pushViewController(addVC!, animated: true)
    }
    
    @IBAction func menuTapped(_ sender: Any) {
                let menuVC = storyboard?.instantiateViewController(withIdentifier: "menuViewController") as? SettingsViewController
                navigationController?.pushViewController(menuVC!, animated: true)

    }
    @objc func didGetNotification(_ notification: Notification) {
        let text = notification.object as! String?
        print(text!)
        switch text {
        case "LogOut":
            print("LogOut Recieved")
            logoutUser()
        case "deletedAccount":
            print("deletedAccount Recieved")
            deletedAcccont()
        default:
            print("nil")
        }
    }
    
    func  deletedAcccont(){
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
        // Navigate to sign-in screen or perform any other necessary action
    }
    func logoutUser(){
        print("log out")
        let alert = UIAlertController(title: "Log out of Account?",
                                      message: "",
                                      preferredStyle: .alert)
        alert.view.tintColor = UIColor.label
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { action in
            // Call the signOut function from FirebaseSignIn
            FirebaseSignIn.signOut { error in
                if let error = error {
                    // Handle error (e.g., show error message to user)
                    print("Error signing out: \(error.localizedDescription)")
                } else {
                    // Sign out successful, proceed with next steps (e.g., navigate to sign-in screen)
                    print("Sign out successful")
                    let signInVC = SignInViewController()
                    signInVC.modalPresentationStyle = .fullScreen
                    self.present(signInVC, animated: true, completion: nil)
                    // Navigate to sign-in screen or perform any other necessary action
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }


}

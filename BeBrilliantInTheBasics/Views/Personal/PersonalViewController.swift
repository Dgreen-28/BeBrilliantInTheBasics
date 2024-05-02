//
//  PersonalViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/27/24.
//

import UIKit

class PersonalViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var personalSegmentedCotrol: UISegmentedControl!
    private var personalPageViewController: PersonalPageViewController?

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var addGoalButton: UIButton!
    private var destiny: PersonalPageViewController?
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didGetNotification(_:)),
                                               name: NSNotification.Name("text"),
                                               object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let destination = segue.destination as? PersonalPageViewController
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
    
    @IBAction func menuTapped(_ sender: Any) {
        let menuVC = storyboard?.instantiateViewController(withIdentifier: "menuViewController") as? SettingsViewController
        navigationController?.pushViewController(menuVC!, animated: true)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let addVC = storyboard?.instantiateViewController(withIdentifier: "AddGoalViewController") as? AddGoalViewController
        addVC!.goalPage = "Personal"
        navigationController?.pushViewController(addVC!, animated: true)
    }

    @objc func didGetNotification(_ notification: Notification) {
        let text = notification.object as! String?
        print(text!)
        switch text {
        case "LogOut":
            print("LogOut Recieved")
            logoutUser()
        default:
            print("nil")
        }
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

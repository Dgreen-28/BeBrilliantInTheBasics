//
//  CheckInViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/27/24.
//

import UIKit

class CheckInViewController: UIViewController {

    @IBOutlet weak var checkInSegmentedCotrol: UISegmentedControl!
    private var personalPageViewController: CheckInPageViewController?

    @IBOutlet weak var infoButton: UIButton!
    private var destiny: CheckInPageViewController?
    @IBOutlet weak var notebookImage: UIImageView!
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageName: String
            if UIDevice.current.userInterfaceIdiom == .pad {
                backgroundImageName = "CheckIn2"
            } else if UIDevice.current.userInterfaceIdiom == .phone {
                backgroundImageName = "CheckIn1"
            } else {
                backgroundImageName = "CheckIn1"
            }
        notebookImage.image = UIImage(named: backgroundImageName)
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let destination = segue.destination as? CheckInPageViewController
        {
            destiny = destination
        }
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        let infopageVC = InfoPageViewController()
        infopageVC.infoText = "checkIn Page" // Pass the appropriate case identifier
        infopageVC.modalPresentationStyle = .overCurrentContext
        infopageVC.modalPresentationStyle = .overFullScreen // This will ensure the modal covers the whole screen
        infopageVC.modalTransitionStyle = .crossDissolve // Optional: for a fade transition
        present(infopageVC, animated: true, completion: nil)
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
    
}

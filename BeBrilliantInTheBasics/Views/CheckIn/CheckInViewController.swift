//
//  CheckInViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/27/24.
//

import GoogleMobileAds
import UIKit

class CheckInViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var checkInSegmentedCotrol: UISegmentedControl!
    private var personalPageViewController: CheckInPageViewController?

    @IBOutlet weak var infoButton: UIButton!
    private var destiny: CheckInPageViewController?
    @IBOutlet weak var notebookImage: UIImageView!
    
    private let banner: GADBannerView = {
        let banner = GADBannerView()
        banner.adUnitID = "ca-app-pub-3709637295446963/3949085655"
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner }()
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Determine the background image based on device type
        let backgroundImageName: String
          if UIDevice.current.userInterfaceIdiom == .pad {
              backgroundImageName = "CheckIn2"
          } else {
              backgroundImageName = "CheckIn1"
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
//                backgroundImageName = "CheckIn2"
//            } else if UIDevice.current.userInterfaceIdiom == .phone {
//                backgroundImageName = "CheckIn1"
//            } else {
//                backgroundImageName = "CheckIn1"
//            }
//        notebookImage.image = UIImage(named: backgroundImageName)
        
        // Do any additional setup after loading the view.
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

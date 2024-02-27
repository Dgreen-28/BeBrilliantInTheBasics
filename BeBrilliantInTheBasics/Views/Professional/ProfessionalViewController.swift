//
//  ProfessionalViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/18/24.
//

import Foundation
import UIKit

class ProfessionalViewController: UIViewController {

    
    @IBOutlet weak var professionalSegmentedCotrol: UISegmentedControl!
    private var professionalPageViewController: ProfessionalPageViewController?

    private var destiny: ProfessionalPageViewController?
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set separator insets programmatically
        
        // Present SignInViewController modally
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen // Set modal presentation style to fullscreen
        present(signInVC, animated: true, completion: nil)
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
    


}


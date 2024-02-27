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

    private var destiny: PersonalPageViewController?
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
}

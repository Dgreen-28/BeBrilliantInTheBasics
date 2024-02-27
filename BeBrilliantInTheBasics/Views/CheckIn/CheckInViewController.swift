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

    private var destiny: CheckInPageViewController?
    
    var indexOfCurrentModel:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let destination = segue.destination as? CheckInPageViewController
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

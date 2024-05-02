//
//  CheckInGroupViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit

class CheckInGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.reloadData()
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.backgroundColor = UIColor.clear
    }

}

extension CheckInGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestData.checkInGroupGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
        let goal = TestData.checkInGroupGoals[indexPath.row]
        cell.goalLabel.text = goal.title
        cell.selectionStyle = .default
        cell.statusImage.image = UIImage(named: goal.statusImageName)
        cell.viewerImage.image = UIImage(systemName: goal.viewerImageName)
//        print("tapped\(indexPath.row)")

        // Set the initial status of the cell
//        cell.isCheckboxChecked = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Set the height of the table view cell to 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RepeatTableViewCell {
            // Toggle the status of the cell
            print("tapped\(indexPath.row)")
            
//            cell.isCheckboxChecked.toggle()
            // Update the image based on the status
//            cell.statusImage.image = UIImage(named: cell.isCheckboxChecked ? "Checkbox_A" : "Checkbox_B")
            //            cell.statusImage.image = UIImage(named: cell.isCheckboxChecked ? "Checkbox_A" : cell.isCheckboxChecked ? "Checkbox_B" : "Checkbox_")

        }
        
        // Deselect the row after tapping
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

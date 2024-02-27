//
//  ProfessionalIndividualViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit

class ProfessionalIndividualViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: "repeatCell")
        tableView.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
    }
    

}
extension ProfessionalIndividualViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestData.professionalIndividualGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
        let goal = TestData.professionalIndividualGoals[indexPath.row]
        
        cell.goalLabel.text = goal.title
        cell.statusImage.image = UIImage(named: goal.statusImageName)
        cell.viewerImage.image = UIImage(systemName: goal.viewerImageName)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Set the height of the table view cell to 100
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { (_) -> UIMenu? in
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { _ in
                    // Implement delete action if needed
                    // This closure will be called when the "Delete" action is selected from the context menu
                    // You can put your delete logic here
                }

            let markAsCompletedAction = UIAction(
                title: "Mark as Completed",
                image: UIImage(systemName: "checkmark.circle")) { _ in
                    // Implement mark as completed action if needed
                    // This closure will be called when the "Mark as Completed" action is selected from the context menu
                }

            let markAsIncompleteAction = UIAction(
                title: "Mark as Incomplete",
                image: UIImage(systemName: "circle")) { _ in
                    // Implement mark as incomplete action if needed
                    // This closure will be called when the "Mark as Incomplete" action is selected from the context menu
                }

            return UIMenu(title: "", children: [deleteAction, markAsCompletedAction, markAsIncompleteAction])
        }
        return config
    }
}

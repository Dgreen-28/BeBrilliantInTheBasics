//
//  PersonalGroupViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/5/24.
//

import UIKit

class PersonalGroupViewController: UIViewController {

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

extension PersonalGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestData.personalGroupGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
        let goal = TestData.personalGroupGoals[indexPath.row]
        cell.goalLabel.text = goal.title
        cell.statusImage.image = UIImage(named: goal.statusImageName)
        cell.viewerImage.image = UIImage(systemName: goal.viewerImageName)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Set the height of the table view cell to 100
    }
}

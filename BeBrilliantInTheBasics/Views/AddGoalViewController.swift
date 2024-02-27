//
//  AddGoalViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/4/24.
//

import UIKit

class AddGoalViewController: UIViewController {
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var checkInRepeatPicker: UIPickerView!
    @IBOutlet weak var CheckInQTextView: UITextView!
    @IBOutlet weak var AddGoalButton: UIButton!
    
    // Data source for the picker
    let checkInRepeatOptions = ["None", "Daily", "Weekly", "Weekly", "Bi-weekly", "Monthly", "Quarterly", "Yearly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        
        // Set delegates for text view and picker view
        checkInRepeatPicker.dataSource = self
        checkInRepeatPicker.delegate = self
        
        // Customize button and text view appearance
        AddGoalButton.layer.cornerRadius = 8.0
        CheckInQTextView.layer.cornerRadius = 8.0
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddGoalTapped(_ sender: Any) {
        // Implement Add Goal functionality here
    }
}

extension AddGoalViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Number of columns in picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return checkInRepeatOptions.count // Number of rows in picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return checkInRepeatOptions[row] // Text for each row
    }
}

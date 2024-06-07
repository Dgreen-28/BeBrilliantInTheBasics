//
//  NotificationsViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 6/5/24.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private var notificationPicker: UIPickerView!
    private var saveButton: UIButton!
    
    private let notificationOptions = ["None", "Once a Day", "Twice a Day", "Three Times a Day", "Weekly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestNotificationPermission()
        loadSavedNotificationPreference()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "Notification Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        notificationPicker = UIPickerView()
        notificationPicker.dataSource = self
        notificationPicker.delegate = self
        notificationPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationPicker)

        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .accent
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            notificationPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            notificationPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: notificationPicker.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] (granted, error) in
            if granted {
                print("Notification permission granted.")
                
                
            } else {
                print("Notification permission denied.")
                DispatchQueue.main.async {
                    self?.showNotificationPermissionAlert()
                }
            }
        }
    }
    
    private func showNotificationPermissionAlert() {
        let alertController = UIAlertController(title: "Notifications Disabled", message: "Please enable notifications in your device settings to receive reminders.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }

    @objc private func saveButtonTapped() {
        let selectedOption = notificationOptions[notificationPicker.selectedRow(inComponent: 0)]
        UserDefaults.standard.set(selectedOption, forKey: "selectedNotificationOption")
        scheduleNotifications(for: selectedOption)
        
        let alertController = UIAlertController(title: "Saved", message: "Your notification preferences have been saved.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    private func loadSavedNotificationPreference() {
        if let savedOption = UserDefaults.standard.string(forKey: "selectedNotificationOption"),
           let index = notificationOptions.firstIndex(of: savedOption) {
            notificationPicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            notificationPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }

    private func scheduleNotifications(for option: String) {
        let center = UNUserNotificationCenter.current()
        
        // Define all possible identifiers
        let identifiers = ["daily", "twiceNoon", "twiceEvening", "thriceMorning", "thriceNoon", "thriceEvening", "weekly"]

        // Remove only the specific goal-related notifications
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        switch option {
        case "Once a Day": // Once a day at 4 PM
            scheduleNotification(at: 16, minute: 0, identifier: "daily")
        case "Twice a Day": // Twice a day at 12 PM and 8 PM
            scheduleNotification(at: 12, minute: 0, identifier: "twiceNoon")
            scheduleNotification(at: 20, minute: 0, identifier: "twiceEvening")
        case "Three Times a Day": // Three times a day at 8 AM, 12 PM, and 8 PM
            scheduleNotification(at: 8, minute: 0, identifier: "thriceMorning")
            scheduleNotification(at: 12, minute: 0, identifier: "thriceNoon")
            scheduleNotification(at: 20, minute: 0, identifier: "thriceEvening")
        case "Weekly": // Weekly on Sunday at 5 PM
            scheduleWeeklyNotification(at: 17, minute: 0, weekday: 1, identifier: "weekly")
        default:
            break
        }
    }

    private func scheduleNotification(at hour: Int, minute: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Check-In"
        content.body = "It's time to check in on your goals!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func scheduleWeeklyNotification(at hour: Int, minute: Int, weekday: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Check-In"
        content.body = "It's time to check in on your goals!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = weekday

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notificationOptions.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return notificationOptions[row]
    }
}

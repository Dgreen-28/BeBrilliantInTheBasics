//
//  SettingsViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 3/24/24.
//

import UIKit
import Foundation

struct SettingsCellModel {
    let title: String
    let image: String
    let handler: (() -> Void)
}


class SettingsViewController: UIViewController {
    
    var option = ""
    
    @IBOutlet weak var settingsTableView: UITableView!
    private var data = [[SettingsCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didGetNotification(_:)),
                                               name: NSNotification.Name("text"),
                                               object: nil)
        
        configureModels()
        self.settingsTableView.reloadData()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("text"), object: option)
    }
    private func configureModels(){
        let section = [
            SettingsCellModel(title: "Account information", image: "person.crop.circle") { [weak self] in
                self?.didTapAccountInfo()
            },
            SettingsCellModel(title: "Search Users", image: "magnifyingglass") { [weak self] in
                self?.didTapSearch()
            },
            SettingsCellModel(title: "Added Users", image: "person.3.fill") { [weak self] in
                self?.didTapUserList()
            },
            SettingsCellModel(title: "Group Check-in Transcript", image: "book.pages") { [weak self] in
                self?.didTranscript()
            },
            SettingsCellModel(title: "Notifications", image: "bell") { [weak self] in
                self?.didTapNotifications()
            },
            SettingsCellModel(title: "Help", image: "questionmark.circle") { [weak self] in
                self?.didTapHelp()
            }, //envelope.fill
            SettingsCellModel(title: "Contact Us", image: "envelope") { [weak self] in
                self?.didTapContact()
            },
            SettingsCellModel(title: "FAQs", image: "questionmark.bubble") { [weak self] in
                self?.didTapFAQs()
            },
            SettingsCellModel(title: "Terms of service", image: "book.closed") { [weak self] in
                self?.didTapTerms()
            },
            SettingsCellModel(title: "Privacy", image: "lock") { [weak self] in
                self?.didTapPrivacy()
            },
            SettingsCellModel(title: "Log out", image: "rectangle.portrait.and.arrow.right") { [weak self] in
                self?.didTapLogOut()
            }
        ]
        data.append(section)
    }
    func didTapAccountInfo(){
        let accountInfoVC = AccountViewController()
        self.navigationController?.pushViewController(accountInfoVC, animated: true)
        print("Account info")
    }
    func didTapSearch(){
        print("Search")
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchUserViewController") as? FindUsersViewController
        navigationController?.pushViewController(searchVC!, animated: true)
    }
    func didTapUserList(){
        let viewUsersVC = ViewUsersViewController()
        self.navigationController?.pushViewController(viewUsersVC, animated: true)
        print("UserList")
    }
    func didTapContact(){
        let contactUsVC = ContactUsViewController()
        self.navigationController?.pushViewController(contactUsVC, animated: true)
        print("UserList")
    }
    
    
    func didTranscript() {
        let alert = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
        
        let allAction = UIAlertAction(title: "All", style: .default) { _ in
            self.navigateToView(option: "All")
        }
        
        let personalAction = UIAlertAction(title: "Personal", style: .default) { _ in
            self.navigateToView(option: "Personal")
        }
        
        let professionalAction = UIAlertAction(title: "Professional", style: .default) { _ in
            self.navigateToView(option: "Professional")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(allAction)
        alert.addAction(personalAction)
        alert.addAction(professionalAction)
        alert.addAction(cancelAction)
        
        // Check if running on iPad to prevent crash
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view // Adjust to your source view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true, completion: nil)
    }

     // Navigation logic based on the selected option
     func navigateToView(option: String) {
         switch option {
         case "All":
             // Navigate to All View
             let allViewController = TranscriptViewController()
             allViewController.group = "All"
             self.navigationController?.pushViewController(allViewController, animated: true)
         case "Personal":
             // Navigate to Personal View
             let personalViewController = TranscriptViewController()
             personalViewController.group = "Personal"
             self.navigationController?.pushViewController(personalViewController, animated: true)
         case "Professional":
             // Navigate to Professional View
             let professionalViewController = TranscriptViewController()
             professionalViewController.group = "Professional"
             self.navigationController?.pushViewController(professionalViewController, animated: true)
         default:
             break
         }
     }
 
    func didTapNotifications(){
        let notificationsVC = NotificationsViewController()
        self.navigationController?.pushViewController(notificationsVC, animated: true)
        print("Notifications")
    }
    func didTapHelp(){
        openYouTubeVideo()
        print("Help!")
    }
    func didTapFAQs(){
        let FAQsVC = FAQsViewController()
        self.navigationController?.pushViewController(FAQsVC, animated: true)
        print("FAQs")
    }
    func didTapTerms() {
        if let url = URL(string: "https://doc-hosting.flycricket.io/bebrilliantinthebasics-terms-of-use/8cdb86cd-f9a6-41b5-95d7-866f14fee6fd/terms") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        print("Terms")
    }
    func didTapPrivacy(){
        if let url = URL(string: "https://doc-hosting.flycricket.io/bebrilliantinthebasics-privacy-policy/accf77d3-5faf-4f13-ae8f-0f102738a4aa/privacy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        print("privacy")
    }
    func didTapLogOut() {
        // TODO: dismiss this view and then call logout from the previous VC

                option = "LogOut"
        self.navigationController?.popViewController(animated: true)

    }
    @objc func didGetNotification(_ notification: Notification) {
        let text = notification.object as! String?
        print(text!)
        switch text {
        case "deletedAccount":
            option = "deletedAccount"
    self.navigationController?.popViewController(animated: true)
        default:
            print("nil")
        }
    }
    func openYouTubeVideo() {
        let videoID = "rBNkZcwa7GA"
        let youtubeAppURL = URL(string: "youtube://\(videoID)")!
        let youtubeWebURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
        
        if UIApplication.shared.canOpenURL(youtubeAppURL) {
            UIApplication.shared.open(youtubeAppURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(youtubeWebURL, options: [:], completionHandler: nil)
        }
    }

}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
        cell.cellLabel?.text = data[indexPath.section][indexPath.row].title
        cell.cellImage?.image = UIImage(systemName: data[indexPath.section][indexPath.row].image)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath){
        tableView.deselectRow(at: indexpath, animated: true)
        data[indexpath.section][indexpath.row].handler()
    }
}

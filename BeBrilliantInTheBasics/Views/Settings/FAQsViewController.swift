//
//  FAQsViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 7/1/24.
//

import UIKit
import MessageUI

class FAQsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    private var faqs: [FAQ] = [
        FAQ(question: "How do I add a goal?", answer: """
    To add a goal, tap the plus button at the top right of either the personal or professional section. On the Add Goals page, fill in the goal attributes:

    • Goal Name: E.g., "Read for 20 minutes a day."
    • Start and End Date: Set the duration for your goal.
    • Repeat Schedule: Choose how often this goal should repeat (daily, weekly, etc.).
    • Category: Select either personal or professional.
    • Check-in Question: This will auto-generate based on your goal name, but you can customize it.
    
    Once done, tap "Add Goal" to save it.
    """, isExpanded: false),
        FAQ(question: "How do I check in on a goal?", answer: """
    In the check-in section at the bottom right, you’ll find your goal's check-ins. Tap the check-in question to toggle the goal’s status. For example, if you’ve completed the activity for the day, mark it as complete and tap submit.
    """, isExpanded: false),
        FAQ(question: "How can I view and edit my goals?", answer: """
    To view a goal's status and check-in history, tap the goal in the personal or professional section. You can edit the check-in history if needed, however, you can only edit the goal if you are the creator of the goal.
    """, isExpanded: false),
        FAQ(question: "What are viewers, and how do I add them to my goals?", answer: """
    Viewers are people you invite to see your goals. To add viewers:

    1. Create a new goal or edit an existing one.
    2. Add colleagues, friends, or family members as viewers.
    
    Viewers can see shared goals if both users have added each other. Shared goals appear on the group page in the check-in section.
    """, isExpanded: false),
        FAQ(question: "How do I remove myself as a viewer from someone else's goal?", answer: """
    On the group page of the personal section, find the goal you’re a viewer of. Press and hold the goal to remove yourself.
    """, isExpanded: false),
        FAQ(question: "What can I do from the menu options?", answer: """
    The menu options allow you to:

    • Set up your notification schedule
    • Access account information
    • Search for and add users
    • View added users
    """, isExpanded: false),
        FAQ(question: "What is the order that goals appear?", answer: """
    Goals will always appear by start date in descending order for both individual and group goals.
    """, isExpanded: false),
        FAQ(question: "Where can I find additional help and tips?", answer: """
    Information buttons are available on various pages of the app, providing guidance and tips to help you navigate and use the app effectively.
    """, isExpanded: false),
        FAQ(question: "Need further assistance or have feedback?", answer: """
    If you have any questions or feedback, please reach out to us at bebrilliantinthebasics@gmail.com. We're here to help!
    """, isExpanded: false)
    ]

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FAQTableViewCell.self, forCellReuseIdentifier: FAQTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "FAQs"
        
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCell.identifier, for: indexPath) as? FAQTableViewCell else {
            return UITableViewCell()
        }
        
        let faq = faqs[indexPath.row]
        cell.configure(with: faq)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        faqs[indexPath.row].isExpanded.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let faq = faqs[indexPath.row]
        if faq.isExpanded {
            let textHeight = faq.answer.heightWithConstrainedWidth(width: tableView.frame.width - 32, font: UIFont.systemFont(ofSize: 16))
            return textHeight + 80
        } else {
            return 60
        }
    }

    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["bebrilliantinthebasics@gmail.com"])
            mail.setSubject("Assistance/Feedback")
            present(mail, animated: true)
        } else {
            // Show an alert informing the user that mail services are not available
            let alert = UIAlertController(title: "Mail Services Not Available", message: "Mail services are not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}


class FAQTableViewCell: UITableViewCell {
    static let identifier = "FAQTableViewCell"
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let answerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerLabel)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 8),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with faq: FAQ) {
        questionLabel.text = faq.question
        answerLabel.text = faq.answer
        answerLabel.isHidden = !faq.isExpanded
    }
}
struct FAQ {
    let question: String
    let answer: String
    var isExpanded: Bool
}

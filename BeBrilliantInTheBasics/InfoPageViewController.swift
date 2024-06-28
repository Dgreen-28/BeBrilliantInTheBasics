//
//  InfoPageViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 6/26/24.
//

import UIKit

class InfoPageViewController: UIViewController {

    var infoText: String? // This will hold the case identifier
    private let infoTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the view's appearance
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // semi-transparent black background
        
        // Set up the infoTextView
        infoTextView.isEditable = false
        infoTextView.backgroundColor = UIColor.white//.withAlphaComponent(0.9)
        infoTextView.layer.cornerRadius = 10
        infoTextView.layer.masksToBounds = true
        infoTextView.textAlignment = .center
        infoTextView.font = UIFont.systemFont(ofSize: 16)
        
        // Set the text based on the infoText
        switch infoText {
        case "setupGoal":
            infoTextView.text = """
            On this page, you can add and edit your goals!

            Give your goal a name, set start and end dates, choose a check-in schedule, select the goal type, and add a check-in question.

            You can also make it a group goal by adding viewers from your list of users
            """
//            "On this page you can add & edit your Goals! \n \n Add a name, give it a start & end date, choose it's check in schedule, choose the goal type and a check in question. \n \n You can also make this a group goal by adding viewers from your list of added users."
        case "checkIn Page":
            infoTextView.text = """
            This Check-in tab helps you track the status of your goals.

            
            • Individual Page: Goals with no viewers.
            • Group Page: Goals with viewers.

            
            Check-in questions for each goal appear on scheduled days. Tap the goal check in question to toggle the status, then tap 'Submit Goals' to update.
            """
//            infoTextView.text = "This is the Check in tab, here you will keep up with the status of your goals. \n \n Goals with no viewers will show up on the individual page & goals with viewers will appear on the group page. \n \n This page shows the check in question of each goal, and will appear on the days they were scheduled to repeat. \n \n You can toggle through the goal status for each goal by tapping the check in question, then tap \"Submit Goals\" to update the goal status."
        case "personal Page":
            infoTextView.text = """
            The Personal section shows all your personal goals.

            • Individual Page: Your created goals.
            • Group Page: Goals you've been added to.

            Click any goal to see its check-in history. Click and hold a goal for more options.
            """
//            infoTextView.text = "This is the Personal tab, here you can see all of your personal goals. \n \n The Individual page will show all the goals you created, and the Group page will show you all the goals that you have been added to. \n \n You can click any goal to see the its check in history. \n \n You can also click and hold a goal to present other options."
        case "professional Page":
            infoTextView.text = """
            The Professional section shows all your professional goals.

            • Individual Page: Your created goals.
            • Group Page: Goals you've been added to.

            Click any goal to see its check-in history. Click and hold a goal for more options.
            """
//            infoTextView.text = "This is the Professional tab, here you can see all of your professional goals. \n \n The Individual page will show all the goals you created, and the Group page will show you all the goals that you have been added to. \n \n You can click any goal to see the its check in history. \n \n You can also click and hold a goal to present other options."
        case "checkIn Data Page":
            infoTextView.text = """
            This page displays the check-in history for your goal.

            Every time you mark your goal as complete or incomplete, it’s recorded here.

            If you created the goal, you can tap on any entry to edit it in case you made a mistake.
            """
        case "notification Page":
            infoTextView.text = """
            When you set up your notification schedule, the options are:
            
            • None: no notifications
            
            • Once a day: 4 PM
            
            • Twice a day: 12 PM & 8 PM
            
            • 3 times a day: 8 AM, 12 PM, & 8 PM
            
            • Weekly on Sunday: 5 PM
            """
        case "manual checkIn Page":
            infoTextView.text = """
            This page allows you to manually check in for goals if you miss a day.

            Select the date, toggle between complete and incomplete, and press 'Submit Goal' to save your check-in.
            """

        case "add Viewers Page":
            infoTextView.text =  """
            Here, you can manage users who can view your goals.

            Ensure that they have added you as well, otherwise, the goal will not appear on their side.
            """

        case "anotherCase":
            infoTextView.text = "Information about another case"
        // Add more cases as needed
            
        default:
            infoTextView.text = "Default information"
        }
        
        // Add the text view to the view controller's view
        view.addSubview(infoTextView)
        
        // Set up constraints for the infoTextView
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoTextView.widthAnchor.constraint(equalToConstant: 300),
            infoTextView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Vertically center the text
            centerTextVertically()
            
            // Add a tap gesture recognizer to dismiss the view
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            centerTextVertically()
        }

        private func centerTextVertically() {
            let fittingSize = infoTextView.sizeThatFits(CGSize(width: infoTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            let topOffset = max(0, (infoTextView.bounds.size.height - fittingSize.height) / 2)
            infoTextView.contentInset.top = topOffset
        }
        
        @objc private func dismissViewController() {
            dismiss(animated: true, completion: nil)
        }
    }

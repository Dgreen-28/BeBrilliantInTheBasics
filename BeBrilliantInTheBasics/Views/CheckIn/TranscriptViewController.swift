//
//  TranscriptViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 7/2/24.
//

import UIKit
import Firebase

class TranscriptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var checkInEntries: [CheckInEntry] = []
    var group = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(group) Group Transcripts"
        setupTableView()
        loadViewerGoalsForFriends()
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CheckInCell.self, forCellReuseIdentifier: "CheckInCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tableView)
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell", for: indexPath) as! CheckInCell
        let checkInEntry = checkInEntries[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: checkInEntry.dateCompleted)

        cell.configure(ownerName: checkInEntry.ownerName, status: checkInEntry.status, goalName: checkInEntry.goalName, dateCompleted: dateStr)
        return cell
    }

    // MARK: - Load Viewer Goals for Friends

    func loadViewerGoalsForFriends() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(currentUser.uid).collection("friends").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching friend list: \(error.localizedDescription)")
                return
            }

            print("Friend list fetched successfully")

            self?.checkInEntries.removeAll()
            let dispatchGroup = DispatchGroup()

            for document in querySnapshot!.documents {
                let friendUID = document.documentID
                print("Friend UID: \(friendUID)")
                dispatchGroup.enter()

                // Create the base query
                var query: Query = db.collection("users").document(friendUID).collection("goals")

                // Conditionally add the filter if group is not "All"
                if self?.group != "All" {
                    query = query.whereField("goalType", isEqualTo: self!.group)
                }

                // Always add the viewers filter
                query = query.whereField("viewers.\(currentUser.uid)", isEqualTo: true)

                query.getDocuments { [weak self] (querySnapshot, error) in
                    defer {
                        dispatchGroup.leave()
                    }

                    guard let self = self else { return }

                    if let error = error {
                        print("Error fetching goals for friend \(friendUID): \(error.localizedDescription)")
                        return
                    }

                    print("Goals fetched successfully for viewer \(currentUser.uid)")

                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let goalName = data["name"] as? String ?? ""
                        var ownerName = "Unknown User"
                        let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                        let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                        let goalType = data["goalType"] as? String ?? ""
                        let checkInSuccessRate = data["checkInSuccessRate"] as? Double ?? 0.0
                        let checkInSchedule = data["checkInSchedule"] as? String ?? ""
                        let checkInQuestion = data["checkInQuestion"] as? String ?? ""
                        var isComplete: String

                        if let isCompleteBool = data["isComplete"] as? Bool {
                            isComplete = isCompleteBool ? "true" : "false"
                        } else {
                            isComplete = data["isComplete"] as? String ?? ""
                        }

                        self.fetchOwnerUsername(for: friendUID) { username in
                            ownerName = username

                            db.collection("users").document(friendUID)
                                .collection("goals").document(document.documentID)
                                .collection("checkins").getDocuments { [weak self] (snapshot, error) in
                                    guard let self = self else { return }

                                    if let error = error {
                                        print("Error fetching check-ins for goal \(document.documentID): \(error.localizedDescription)")
                                        return
                                    }

                                    print("Check-ins fetched successfully for goal \(document.documentID)")

                                    for checkinDocument in snapshot!.documents {
                                        let data = checkinDocument.data()
                                        guard let isComplete = data["isComplete"] as? Bool,
                                              let timestamp = data["dateCompleted"] as? Timestamp else {
                                            continue
                                        }

                                        let dateCompleted = timestamp.dateValue()
                                        let status = isComplete ? "completed" : "incompleted"

                                        let checkInEntry = CheckInEntry(ownerName: ownerName,
                                                                        goalName: goalName,
                                                                        status: status,
                                                                        dateCompleted: dateCompleted)

                                        self.checkInEntries.append(checkInEntry)
                                    }

                                    // Sort the checkInEntries by dateCompleted
                                    self.checkInEntries.sort(by: { $0.dateCompleted > $1.dateCompleted })

                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                print("All goals and check-ins fetched and updated")
            }
        }
    }

    // Function to fetch owner's username
    private func fetchOwnerUsername(for userID: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion("Unknown User")
                return
            }

            guard let document = document, document.exists else {
                print("User document does not exist")
                completion("Unknown User")
                return
            }

            let username = document.data()?["username"] as? String ?? "Unknown User"
            completion(username)
        }
    }
}

// Custom UITableViewCell to improve appearance and handle long text
class CheckInCell: UITableViewCell {
    private let ownerLabel = UILabel()
    private let goalLabel = UILabel()
    private let statusLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        ownerLabel.numberOfLines = 1
        goalLabel.numberOfLines = 1
        statusLabel.numberOfLines = 1
        dateLabel.numberOfLines = 1

        let stackView = UIStackView(arrangedSubviews: [ownerLabel, statusLabel, goalLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func configure(ownerName: String, status: String, goalName: String, dateCompleted: String) {
        ownerLabel.text = "Owner: \(ownerName)"
        goalLabel.text = "Goal: \(goalName)"
        statusLabel.text = "Status: \(status)"
        dateLabel.text = "Date: \(dateCompleted)"
    }
}

struct CheckInEntry {
    var ownerName: String
    var goalName: String
    var status: String
    var dateCompleted: Date
}

//
//  TestViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 3/17/24.
//



import UIKit

class TestViewController: UIViewController {
    
    var friends: [String] = [
        "Friend 1", "Friend 2", "Friend 3", "Friend 4", "Friend 5",
        "Friend 6", "Friend 7", "Friend 8", "Friend 9", "Friend 10",
        "Friend 11", "Friend 12", "Friend 13", "Friend 14", "Friend 15",
        "Friend 16", "Friend 17", "Friend 18", "Friend 19", "Friend 20",
        "Friend 21", "Friend 22", "Friend 23", "Friend 24", "Friend 25",
        "Friend 26", "Friend 27", "Friend 28", "Friend 29", "Friend 30",
        "Friend 31", "Friend 32", "Friend 33", "Friend 34", "Friend 35",
        "Friend 36", "Friend 37", "Friend 38", "Friend 39", "Friend 40"
    ]
    
    var filteredFriends: [String] = [] // For storing filtered friends
    
    var checkedFriends: [String] = []
    
    var tableViewContainerView: UIView!
    var tableView: UITableView!
    var closeButton: UIButton!
    var showTableViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray background
        
        setupViews()
    }
    
    func setupViews() {
        // Button to show/hide the tableView
        showTableViewButton = UIButton()
        showTableViewButton.translatesAutoresizingMaskIntoConstraints = false
        showTableViewButton.setTitle("Show Friends", for: .normal)
        showTableViewButton.setTitleColor(.white, for: .normal)
        showTableViewButton.backgroundColor = .blue
        showTableViewButton.layer.cornerRadius = 8
        showTableViewButton.layer.shadowColor = UIColor.black.cgColor
        showTableViewButton.layer.shadowOpacity = 0.5
        showTableViewButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        showTableViewButton.layer.shadowRadius = 4
        showTableViewButton.addTarget(self, action: #selector(showHideTableView), for: .touchUpInside)
        view.addSubview(showTableViewButton)
        
        NSLayoutConstraint.activate([
            showTableViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showTableViewButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            showTableViewButton.widthAnchor.constraint(equalToConstant: 150),
            showTableViewButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // TableView Container View
        tableViewContainerView = UIView()
        tableViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        tableViewContainerView.backgroundColor = .white
        tableViewContainerView.layer.cornerRadius = 8
        tableViewContainerView.layer.shadowColor = UIColor.black.cgColor
        tableViewContainerView.layer.shadowOpacity = 0.5
        tableViewContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableViewContainerView.layer.shadowRadius = 4
        view.addSubview(tableViewContainerView)
        
        NSLayoutConstraint.activate([
            tableViewContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableViewContainerView.topAnchor.constraint(equalTo: showTableViewButton.bottomAnchor, constant: 20),
            tableViewContainerView.widthAnchor.constraint(equalToConstant: 300),
            tableViewContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200) // Adjusted constraint
        ])
        
        // TableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewContainerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableViewContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableViewContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableViewContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableViewContainerView.bottomAnchor) // Adjusted constraint
        ])
        
        // Close Button
        closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .red
        closeButton.layer.cornerRadius = 8
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.5
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 4
        closeButton.addTarget(self, action: #selector(closeTableView), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: tableViewContainerView.bottomAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Initially hide the tableView and closeButton
        tableViewContainerView.isHidden = true
        closeButton.isHidden = true
    }
    
    @objc func showHideTableView() {
        UIView.animate(withDuration: 0.3) {
            self.tableViewContainerView.isHidden = !self.tableViewContainerView.isHidden
            self.closeButton.isHidden = !self.closeButton.isHidden
        }
    }
    
    @objc func closeTableView() {
        UIView.animate(withDuration: 0.3) {
            self.tableViewContainerView.isHidden = true
            self.closeButton.isHidden = true
        }
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count + 1 // Add 1 for the search bar cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Create a cell for the search bar
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let searchBar = UISearchBar()
            searchBar.placeholder = "Search Friends"
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchBar.delegate = self // Set delegate to handle search bar events
            cell.contentView.addSubview(searchBar)
            
            NSLayoutConstraint.activate([
                searchBar.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                searchBar.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                searchBar.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                searchBar.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
            return cell
        } else {
            let friendIndex = indexPath.row - 1 // Adjusted index to account for search bar cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let friend = filteredFriends[friendIndex]
            cell.textLabel?.text = friend
            
            if checkedFriends.contains(friend) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 { // Exclude search bar cell
            let friendIndex = indexPath.row - 1 // Adjusted index to account for search bar cell
            let selectedFriend = filteredFriends[friendIndex]
            if checkedFriends.contains(selectedFriend) {
                // Friend already checked, so remove from checkedFriends
                if let index = checkedFriends.firstIndex(of: selectedFriend) {
                    checkedFriends.remove(at: index)
                }
            } else {
                // Friend not checked, so add to checkedFriends
                checkedFriends.append(selectedFriend)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TestViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search text changed: \(searchText)")
        if searchText.isEmpty {
            // If search text is empty, show all friends
            filteredFriends = friends
        } else {
            // Filter friends based on search text (matching full words)
            filteredFriends = friends.filter { friend in
                let words = friend.components(separatedBy: " ")
                return words.contains { $0.lowercased() == searchText.lowercased() }
            }
        }
        
        tableView.reloadData() // Reload table view to reflect the changes
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        filteredFriends = friends
        tableView.reloadData()
    }
}

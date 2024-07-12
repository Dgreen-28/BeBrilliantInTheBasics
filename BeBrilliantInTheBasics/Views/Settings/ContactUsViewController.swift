//
//  ContactUsViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 7/12/24.
//

import UIKit

class ContactUsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let items: [(String, String, URL?)] = [
        ("App Support", "bebrilliantinthebasics@gmail.com", nil),
        ("Developer Contact", "d.green2899@gmail.com", nil),
        ("Website", "", URL(string: "https://bebrilliantinthebasics.com"))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        self.title = "Contact Us"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.section]
        
        if let email = item.1 as String?, !email.isEmpty {
            cell.textLabel?.text = email
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .clear
        } else if let url = item.2 {
            cell.textLabel?.text = url.absoluteString
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .clear
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        
        if let email = item.1 as String?, !email.isEmpty, let url = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if let url = item.2 {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

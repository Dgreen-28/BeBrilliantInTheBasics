//
//  Extensions.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/1/24.
//

import Foundation
import UIKit
import SwiftUI
import UserNotifications

extension UIView {
    // For laying out views with code

    public var width: CGFloat { return frame.size.width }
    public var height: CGFloat { return frame.size.height }
    public var top: CGFloat { return frame.origin.y }
    public var bottom: CGFloat { return frame.origin.y + frame.size.height }
    public var left: CGFloat { return frame.origin.x }
    public var right: CGFloat { return frame.origin.x + frame.size.width }
    
    func setCellShadow() {
        self.layer.cornerRadius = 15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.2
        self.layer.shadowOpacity = 0.55
    }
    
}
extension UIViewController {
    func setupTableView(tableView: UITableView, reuseIdentifier: String, isBottomSheet: Bool) {
        let safeArea = view.layoutMarginsGuide
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if isBottomSheet == true {
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40).isActive = true
        }else {
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true
        }
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    static func instance(storyboard: String, id: String) -> Self {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
    
    static func getVC(storyboardName: String, controllerID: String) -> Self {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(identifier: controllerID) as! Self
    }
}

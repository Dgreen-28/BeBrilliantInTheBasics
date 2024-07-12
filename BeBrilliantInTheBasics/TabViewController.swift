//
//  TabViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/27/24.
//


import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate
        self.delegate = self

        // Set up your custom tab bar images
        if let tabBarItems = tabBar.items {
            tabBarItems[0].image = UIImage(named: "Professional-Clear")?.withRenderingMode(.alwaysOriginal)
            tabBarItems[0].selectedImage = UIImage(named: "Professional-Color")?.withRenderingMode(.alwaysOriginal)

            tabBarItems[1].image = UIImage(named: "Personal-Clear")?.withRenderingMode(.alwaysOriginal)
            tabBarItems[1].selectedImage = UIImage(named: "Personal-Color")?.withRenderingMode(.alwaysOriginal)
            
            tabBarItems[2].image = UIImage(named: "Checkin-Clear")?.withRenderingMode(.alwaysOriginal)
            tabBarItems[2].selectedImage = UIImage(named: "Checkin-Color")?.withRenderingMode(.alwaysOriginal)
        }

        // Disable tint color to avoid color overlay
        tabBar.tintColor = UIColor.clear
        tabBar.unselectedItemTintColor = UIColor.clear

        // Debug logging
        print("TabViewController viewDidLoad")
    }

    // Implement the delegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle tab selection
        if let selectedIndex = viewControllers?.firstIndex(of: viewController) {
            print("Selected tab index: \(selectedIndex)")
        }
    }
}

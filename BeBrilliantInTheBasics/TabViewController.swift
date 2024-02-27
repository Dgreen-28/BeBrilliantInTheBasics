//
//  TabViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 1/27/24.
//


import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up your custom tab bar images
        if let tabBarItems = tabBar.items {
            // Replace "your_unselected_image" and "your_selected_image" with your actual image names
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
        

    }
}

//
//  CheckInPageViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit

class CheckInPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    
    private var pages: [UIViewController] = []

    private var destiny: CheckInViewController?
    var indexOfCurrentModel:Int?
    
    let personalVc = CheckInViewController.instance(storyboard: "Main", id: "CheckInView")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let checkInIndividual = CheckInIndividualViewController.instance(storyboard: "Main", id: "checkInIndividual")
        let checkInGroup = CheckInGroupViewController.instance(storyboard: "Main", id: "checkInGroup")
        pages.append(checkInIndividual)
        pages.append(checkInGroup)
        self.dataSource = nil
        self.delegate = self
        // Do any additional setup after loading the view.
        self.setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == pages[1] { return pages[0] }
        else { return nil }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == pages[0] { return pages[1] }
        else { return nil }
    }
    func goto(index: Int)
    {
        switch index {
        case 1 :
            self.setViewControllers([pages[index]], direction: .forward, animated: true)
            print("GroupVC")
        default:
            self.setViewControllers([pages[index]], direction: .reverse, animated: true)
            print("IndividualVC")

        }
    }

}

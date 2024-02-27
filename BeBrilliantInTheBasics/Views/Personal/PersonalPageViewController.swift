//
//  PersonalPageViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/5/24.
//

import UIKit

class PersonalPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    
    private var pages: [UIViewController] = []

    private var destiny: PersonalViewController?
    var indexOfCurrentModel:Int?
    
    let personalVc = PersonalViewController.instance(storyboard: "Main", id: "PersonalView")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let personalIndividual = PersonalIndividualViewController.instance(storyboard: "Main", id: "personalIndividual")
        let personalGroup = PersonalGroupViewController.instance(storyboard: "Main", id: "personalGroup")
        pages.append(personalIndividual)
        pages.append(personalGroup)
        self.dataSource = nil
        self.delegate = self
        // Do any additional setup after loading the view.
        self.setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let lastPage = String(previousViewControllers.description)
        if lastPage.contains("PersonalGroupViewController") {
            print("personalIndividual")
        }
        else{
            print("personalGroup")
        }
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

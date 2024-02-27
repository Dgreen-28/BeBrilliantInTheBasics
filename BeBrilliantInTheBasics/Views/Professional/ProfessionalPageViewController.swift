//
//  ProfessionalPageViewController.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/7/24.
//

import UIKit

class ProfessionalPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {

    private var pages: [UIViewController] = []

    private var destiny: ProfessionalViewController?
    var indexOfCurrentModel:Int?
    
    let personalVc = ProfessionalViewController.instance(storyboard: "Main", id: "ProfessionalView")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let professionalIndividual = ProfessionalIndividualViewController.instance(storyboard: "Main", id: "professionalIndividual")
        let professionalGroup = ProfessionalGroupViewController.instance(storyboard: "Main", id: "professionalGroup")
        pages.append(professionalIndividual)
        pages.append(professionalGroup)
        self.dataSource = nil
        self.delegate = self
        // Do any additional setup after loading the view.
        self.setViewControllers([pages[0]], direction: .forward, animated: false)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let lastPage = String(previousViewControllers.description)
        if lastPage.contains("PersonalGroupViewController") {
            print("professionalIndividual")
        }
        else{
            print("professionalGroup")
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
            print("GrupVC")
        default:
            self.setViewControllers([pages[index]], direction: .reverse, animated: true)
            print("IndividualVC")

        }
    }
}

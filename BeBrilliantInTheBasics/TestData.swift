//
//  TestData.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/12/24.
//

import Foundation

struct Goal {
    let title: String
    let statusImageName: String
    let viewerImageName: String
    
    init(title: String, statusImageName: String, viewerImageName: String) {
        self.title = title
        self.statusImageName = statusImageName
        self.viewerImageName = viewerImageName
    }
}

struct TestData {
    static let personalIndividualGoals: [Goal] = [
        Goal(title: "Daily Prayer", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Alcohol once a month", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "Eat out once a week", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "workout twice a week", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "No perking tickets", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Save $10k", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Practice spanish daily", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Call parents weekly", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "Buy a house/ find a house", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "Never miss a bill", statusImageName: "Green", viewerImageName: "")
    ]
    static let personalGroupGoals: [Goal] = [
        Goal(title: "Mom: Save $7,000 for vacation", statusImageName: "Green", viewerImageName: "crown"),
        Goal(title: "Wife: Don't crack phone", statusImageName: "Red", viewerImageName: "crown"),
        Goal(title: "Wife: workout twice a week", statusImageName: "Green", viewerImageName: "crown")
    ]
    
    static let professionalIndividualGoals: [Goal] = [
        Goal(title: "Submit timesheet on time", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Use all vacation time", statusImageName: "Yellow", viewerImageName: ""),
        Goal(title: "No late days", statusImageName: "Red", viewerImageName: ""),
        Goal(title: "20 percent increase in productivity", statusImageName: "Green", viewerImageName: ""),
        Goal(title: "Lead 3 client meetings", statusImageName: "Green", viewerImageName: "")
    ]
    static let professionalGroupGoals: [Goal] = [
        Goal(title: "Employee 5: Submit timesheet on time", statusImageName: "Yellow", viewerImageName: "eye"),
        Goal(title: "Employee 3: Clean station nightly", statusImageName: "Green", viewerImageName: "crown")
    ]
        static let checkInGroupGoals: [Goal] = [
        Goal(title: "Mom: Save $7,000 for vacation", statusImageName: "Checkbox_A", viewerImageName: "crown"),
        Goal(title: "Employee 5: Submit timesheet on time", statusImageName: "Checkbox_", viewerImageName: "eye"),
        Goal(title: "Wife: Don't crack phone", statusImageName: "Checkbox_B", viewerImageName: "crown"),
        Goal(title: "Wife: workout twice a week", statusImageName: "Checkbox_A", viewerImageName: "crown"),
        Goal(title: "Employee 3: Clean station nightly", statusImageName: "Checkbox_A", viewerImageName: "crown"),

    ]
    static let checkInIndividualGoals: [Goal] = [
        Goal(title: "Did you pray today?", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Did you eat out past the limit?", statusImageName: "Checkbox_", viewerImageName: ""),
        Goal(title: "No parking tickets", statusImageName: "Checkbox_B", viewerImageName: ""),
        Goal(title: "did you save $200 this week?", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Did you practice español today?", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Did you call your parents today?", statusImageName: "Checkbox_A", viewerImageName: ""),
        Goal(title: "Have you worked out twice this week?", statusImageName: "Checkbox_A", viewerImageName: "")
    ]
    
}

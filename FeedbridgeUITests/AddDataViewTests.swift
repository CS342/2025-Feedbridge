//
//  AddDataViewTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 2/11/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

// import XCTest

// class AddDataAViewUITests: XCTestCase {
//     @MainActor
//     override func setUp() async throws {
//         continueAfterFailure = false

//         let app = XCUIApplication()
//         app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]
//         app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
//     }

//     /// Tests if all data entry buttons exist in the view
//     @MainActor
//     func testDataEntryButtonsExist() {
//         let app = XCUIApplication()
//         let feedEntryButton = app.buttons["Feed Entry"]
//         let wetDiaperButton = app.buttons["Wet Diaper Entry"]
//         let stoolEntryButton = app.buttons["Stool Entry"]
//         let dehydrationCheckButton = app.buttons["Dehydration Check"]
//         let weightEntryButton = app.buttons["Weight Entry"]

//         XCTAssertTrue(feedEntryButton.exists, "Feed Entry button should exist")
//         XCTAssertTrue(wetDiaperButton.exists, "Wet Diaper Entry button should exist")
//         XCTAssertTrue(stoolEntryButton.exists, "Stool Entry button should exist")
//         XCTAssertTrue(dehydrationCheckButton.exists, "Dehydration Check button should exist")
//         XCTAssertTrue(weightEntryButton.exists, "Weight Entry button should exist")
//     }

//     /// Tests tapping each button
//     @MainActor
//     func testTapDataEntryButtons() {
//         let buttons = ["Feed Entry", "Wet Diaper Entry", "Stool Entry", "Dehydration Check", "Weight Entry"]

//         for buttonLabel in buttons {
//             let app = XCUIApplication()
//             let button = app.buttons[buttonLabel]
//             XCTAssertTrue(button.exists, "\(buttonLabel) button should exist")
//             button.tap()
//             // Assert any expected behavior after tapping
//         }
//     }

//     /// Tests if the navigation title is correct
//     @MainActor
//     func testNavigationTitle() {
//         let app = XCUIApplication()
//         XCTAssertTrue(app.staticTexts["Add Data"].exists, "Navigation title should be 'Add Data'")
//     }
// }

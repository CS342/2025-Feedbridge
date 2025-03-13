//
//  WeightTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

@MainActor
class WeightTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--testingMode", "--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
    }

    /// Tests that the weight tracking navigation exists and functions correctly.
    func testWeightEntry() {
        let app = XCUIApplication()

        // Navigate to the dashboard from settings
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()

        // Verify that the "Weights" navigation title is displayed
        let nav = app.staticTexts["Weights"]
        XCTAssertTrue(nav.exists, "Weight navigation should exist")

        // Tap on the first weight entry
        let button = app.buttons["Scale, Weights, Next page, 3.29 kg"]
        button.tap()

        // Check if "Weights" title and sample weight entry exist
        XCTAssertTrue(app.staticTexts["Weights"].exists, "Weight screen title should exist")
        XCTAssertTrue(app.staticTexts["3.29 kg"].exists, "Weight entry should be displayed")

        // Verify the first weight entry cell exists
        let entryCell = app.cells.firstMatch
        XCTAssertTrue(entryCell.exists, "Weight entry should exist before deletion")

        // Swipe left to reveal the delete button
        entryCell.swipeLeft()

        // Ensure the delete button is visible after swiping
        XCTAssertTrue(app.buttons["Delete"].exists, "Delete button should be visible after swipe")
    }
}

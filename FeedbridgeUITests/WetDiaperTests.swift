//
//  WetDiaperTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/13/25.

// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

@MainActor
class WetDiaperTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--testingMode", "--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
    }

    /// Tests that the wet diaper tracking navigation exists and functions correctly.
    func testWetDiaperEntry() {
        let app = XCUIApplication()

        // Navigate to the dashboard from settings
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()

        // Verify that the "Voids" navigation title is displayed
        let nav = app.staticTexts["Voids"]
        XCTAssertTrue(nav.exists, "Wet diaper navigation should exist")

        // Check if "Voids" title and sample wet diaper entry exist
        XCTAssertTrue(app.staticTexts["Voids"].exists, "Voids title should exist")
        XCTAssertTrue(app.staticTexts["Medium and Yellow"].exists, "Wet diaper entry should exist")

        // Tap on the first wet diaper entry
        let button = app.buttons["Wet Diaper Drop, Voids, Next page, Medium and Yellow"]
        button.tap()

        XCTAssertTrue(app.staticTexts["Medium and Yellow"].exists, "Wet diaper entry should exist")

        // Verify the first wet diaper entry cell exists
        let entryCell = app.cells.firstMatch
        XCTAssertTrue(entryCell.exists, "Wet diaper entry should exist before deletion")

        // Swipe left to reveal the delete button
        entryCell.swipeLeft()

        // Ensure the delete button is visible after swiping
        XCTAssertTrue(app.buttons["Delete"].exists, "Delete button should be visible")
    }
}

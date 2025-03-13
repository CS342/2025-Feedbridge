//
//  FeedTests.swift
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
class FeedTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--testingMode", "--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
    }

    /// Tests that the feed navigation exists and displays entries correctly.
    func testFeedNavExists() {
        let app = XCUIApplication()

        // Navigate to the dashboard from settings
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()

        // Verify the "Feeds" section is present
        let nav = app.staticTexts["Feeds"]
        XCTAssertTrue(nav.exists, "Feed navigation should exist")

        // Ensure the mock breastfeeding entry appears in the list
        XCTAssertTrue(app.staticTexts["Breastfeeding: 15 min"].exists, "Feed entry should be visible")

        // Select the first feed entry
        let button = app.buttons["Flame, Feeds, Next page, Breastfeeding: 15 min"]
        button.tap()

        // Verify that the selected feed entry cell exists
        let entryCell = app.cells.firstMatch
        XCTAssertTrue(entryCell.exists, "Feed entry should exist before deletion")

        // Swipe left to reveal the delete button
        entryCell.swipeLeft()

        // Ensure the delete button is visible after swiping
        XCTAssertTrue(app.buttons["Delete"].exists, "Delete button should be visible")
    }
}

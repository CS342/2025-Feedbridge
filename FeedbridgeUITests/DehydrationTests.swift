//
//  DehydrationTests.swift
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
class DehydrationTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--testingMode", "--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
    }

    /// Tests that the dehydration symptoms screen exists and functions correctly.
    func testDehydrationEntry() {
        let app = XCUIApplication()

        // Navigate to the dashboard from settings
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()

        // Verify that the "Dehydration Symptoms" navigation title is displayed
        let nav = app.staticTexts["Dehydration Symptoms"]
        XCTAssertTrue(nav.exists, "Dehydration symptoms navigation should exist")

        // Tap on the first dehydration entry
        let button = app.buttons["Heart icon, Dehydration Symptoms, Next page, 3/9/25, 3/10/25, 3/11/25, 3/12/25, 3/13/25"]
        button.tap()

        // Check if "Dehydration Symptoms" title and sample dehydration alert exist
        XCTAssertTrue(app.staticTexts["Dehydration Symptoms"].exists, "Dehydration screen title should exist")
        XCTAssertTrue(app.staticTexts["⚠️ Alert"].exists, "Dehydration alert should be displayed if conditions are met")
        XCTAssertTrue(app.staticTexts["Dry Mucous Membranes"].exists, "Dehydration symptom should be displayed")

        // Verify the first dehydration entry cell exists
        let entryCell = app.cells.firstMatch
        XCTAssertTrue(entryCell.exists, "Dehydration entry should exist before deletion")

        // Swipe left to reveal the delete button
        entryCell.swipeLeft()

        // Ensure the delete button is visible after swiping
        XCTAssertTrue(app.buttons["Delete"].exists, "Delete button should be visible after swipe")
    }
}

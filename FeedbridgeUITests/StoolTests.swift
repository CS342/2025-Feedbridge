//
//  StoolTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/12/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

@MainActor
class StoolTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--testingMode", "--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
    }
    
    /// Tests that the stool navigation exists and functions correctly.
    func testStoolEntry() {
        let app = XCUIApplication()
        
        // Navigate to the dashboard from settings
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()
        
        // Verify that the "Stools" navigation title is displayed
        let nav = app.staticTexts["Stools"]
        XCTAssertTrue(nav.exists, "Stool navigation should exist")
        
        // Check if "Stools" title and sample stool entry exist
        XCTAssertTrue(app.staticTexts["Stools"].exists, "Stool title should exist")
        XCTAssertTrue(app.staticTexts["Medium and Brown"].exists, "Stool entry should exist")

        // Tap on the first stool entry
        let button = app.buttons["Stool Drop, Stools, Next page, Medium and Brown"]
        button.tap()
        
        // Verify the first stool entry cell exists
        let entryCell = app.cells.firstMatch
        XCTAssertTrue(entryCell.exists, "Stool entry should exist before deletion")
        
        // Swipe left to reveal the delete button
        entryCell.swipeLeft()
        
        // Ensure the delete button is visible after swiping
        XCTAssertTrue(app.buttons["Delete"].exists, "Delete button should be visible")
    }
}

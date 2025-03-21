//
//  AddBabyTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/11/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

@MainActor
class AddBabyTests: XCTestCase {
    /// Sets up the test environment before each test case.
    /// Ensures that there are no existing babies and launches the app with test configurations.
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")

        // Clear existing babies before each test
        deleteAllBabies(app)
    }

    /// Deletes all babies using the UI delete button, ensuring a clean state before each test.
    /// - Parameter app: The XCUIApplication instance.
    private func deleteAllBabies(_ app: XCUIApplication) {
        app.buttons["Settings"].tap()

        let deleteButton = app.buttons["Delete Baby, Delete Baby"]

        // If the delete button exists, repeatedly tap it to remove all babies
        while deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
            app.buttons["Delete"].tap()
        }
    }

    /// Tests the process of adding a new baby and verifying that the baby is correctly displayed in the UI.
    func testAddBaby() {
        let app = XCUIApplication()
        app.buttons["Settings"].tap()

        // Verify initial state: No baby should be selected
        XCTAssertTrue(app.staticTexts["Select Baby"].waitForExistence(timeout: 5), "Select baby dropdown should be visible")
        XCTAssertTrue(app.staticTexts["No baby selected"].waitForExistence(timeout: 5), "No babies should exist")

        // Open the dropdown menu and select "Add New Baby"
        let dropdown = app.buttons["Baby icon, Select Baby, Menu dropdown"]
        dropdown.tap()
        let addNew = app.buttons["Add New Baby"]
        XCTAssertTrue(addNew.waitForExistence(timeout: 10), "Should be an option to add a baby")
        addNew.tap()

        // Ensure that the Save button is initially disabled
        let saveButton = app.buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled initially")

        // Enter baby's name
        let nameField = app.textFields["Baby's Name"]
        nameField.tap()
        nameField.typeText("Benjamin")

        // Verify that a duplicate name warning is not displayed
        XCTAssertFalse(app.staticTexts["This name is already taken"].waitForExistence(timeout: 5), "Duplicate name warning should not appear")

        // Date Picker: Select March 2025 (valid past date)
        let datePickersQuery = app.datePickers.firstMatch
        datePickersQuery.tap()
        app.staticTexts["1"].tap()
        app.buttons["PopoverDismissRegion"].tap() // Close the date picker

        // Ensure the Save button is enabled now that valid data is entered
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled when valid data is entered")

        // Save the baby data
        // Make sure the Save button is visible and hittable
        if !saveButton.isHittable {
            app.swipeUp() // Try scrolling if button isn't visible
            XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should be visible after scrolling")
        }
        
        // Save the baby data with a single tap
        XCTAssertTrue(saveButton.isHittable, "Save button should be hittable")
        saveButton.tap()

        // Verify that the new baby is correctly added and displayed in the UI
        XCTAssertTrue(app.staticTexts["Benjamin"].waitForExistence(timeout: 5), "Baby's name should be displayed")
        XCTAssertTrue(app.buttons["Baby icon, Benjamin, Menu dropdown"].waitForExistence(timeout: 5), "Baby dropdown should show new baby")
        XCTAssertTrue(app.buttons["Delete Baby, Delete Baby"].waitForExistence(timeout: 5), "Delete button should be displayed for the new baby")
        XCTAssertTrue(app.staticTexts["Use Kilograms"].waitForExistence(timeout: 5), "The 'Use Kilograms' text should be displayed")
        
        let healthDetailsCell = app.staticTexts["Health Details"]
        XCTAssertTrue(
            healthDetailsCell.waitForExistence(timeout: 5),
            "Health Details navigation link not found."
        )
        healthDetailsCell.tap()

        let navTitle = app.navigationBars["Health Details"]
        XCTAssertTrue(
            navTitle.waitForExistence(timeout: 5),
            "Did not navigate to Health Details view as expected."
        )
        
        print("DEBUG: Current UI for 'AddEntryView':\n\(app.debugDescription)")

        XCTAssertTrue(app.staticTexts["FEED ENTRIES"].waitForExistence(timeout: 5), "Feed Entries exists")
        XCTAssertTrue(app.staticTexts["WEIGHT ENTRIES"].waitForExistence(timeout: 5), "Weight Entries exists")
        XCTAssertTrue(app.staticTexts["STOOL ENTRIES"].waitForExistence(timeout: 5), "Stool Entries exists")
        XCTAssertTrue(app.staticTexts["VOID ENTRIES"].waitForExistence(timeout: 5), "Void Entries exists")
        XCTAssertTrue(app.staticTexts["DEHYDRATION CHECKS"].waitForExistence(timeout: 5), "Dehydration Checks exists")
    }
}

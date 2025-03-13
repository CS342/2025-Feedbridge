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

class AddBabyTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding", "--resetBabies"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")

//        // Ensure any existing babies are deleted
//        let deleteButton = app.buttons["Delete Baby, Delete Baby"]
//        while deleteButton.exists {
//            deleteButton.tap()
//            app.alerts.buttons["Delete"].tap()
//        }
    }

    @MainActor
    func testDefault() {
        let app = XCUIApplication()
        let nobabylabel = app.staticTexts["No babies found"]
        let caption = app.staticTexts["Please add a baby in Settings before adding entries."]
        
        XCTAssertTrue(nobabylabel.exists, "No babies found should be displayed")
        XCTAssertTrue(caption.exists, "Caption should be displayed")
    }

    @MainActor
    func testAddBaby() {
        let app = XCUIApplication()
        app.buttons["Settings"].tap()
        
        XCTAssertTrue(app.staticTexts["Select Baby"].exists, "Should be displayed")
        XCTAssertTrue(app.staticTexts["No baby selected"].exists, "Should be displayed")
        
        // Select the dropdown menu and add a new baby
        let dropdown = app.buttons["Baby icon, Select Baby, Menu dropdown"]
        dropdown.tap()
        let addNew = app.buttons["Add New Baby"]
        XCTAssertTrue(addNew.exists, "Should be displayed")
        addNew.tap()

        // Ensure that the Save button is initially disabled
        let saveButton = app.buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled initially")

        // Enter baby's name
        let nameField = app.textFields["Baby's Name"]
        nameField.tap()
        nameField.typeText("Benjamin")

        // Ensure no duplicate name warning appears
        XCTAssertFalse(app.staticTexts["This name is already taken"].exists, "Duplicate name warning should not appear")

        // Date Picker: Select March 2025 (valid past date)
        let datePickersQuery = app.datePickers.firstMatch
        datePickersQuery.tap()
        app.staticTexts["1"].tap()
        app.buttons["PopoverDismissRegion"].tap() // Close the date picker
        
        // Ensure the Save button is enabled now that valid data is entered
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled when valid data is entered")

        // Save the baby data
        saveButton.tap()
        
        // Assert the new baby is saved and displayed correctly
        XCTAssertTrue(app.staticTexts["Benjamin"].exists, "Baby's name should be displayed")
        XCTAssertTrue(app.buttons["Baby icon, Benjamin, Menu dropdown"].exists, "Baby dropdown should show new baby")
        XCTAssertTrue(app.buttons["Delete Baby, Delete Baby"].exists, "Delete button should be displayed for the new baby")
        XCTAssertTrue(app.staticTexts["Use Kilograms"].exists, "The 'Use Kilograms' text should be displayed")
    }
}

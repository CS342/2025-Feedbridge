//
//  AddEntryTests.swift
//  FeedbridgeUITests
//
//  Created by Calvin Xu on 3/12/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

/// A test suite covering the AddEntryView in detail.
@MainActor
final class AddEntryTests: XCTestCase {
    /// Sets up the test environment before each test case.
    /// Ensures that there are no existing babies and launches the app with test configurations.
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        // These launch arguments and method calls are placeholders;
        // adjust to match your actual test config or app lifecycle approach.
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]

        // Example helper that can remove all babies so we can test the "No babies found" flow.
        // If you have a different approach, adapt accordingly.
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
        deleteAllBabies(app)
        createTestBaby(app)
    }

    // MARK: - Helpers

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

    /// Optionally, if you need a baby in order to use AddEntryView, create it here.
    /// In some tests we want to see "No babies found", so we won't call this for every test.
    private func createTestBaby(_ app: XCUIApplication, name: String = "TestBaby") {
        app.buttons["Settings"].tap()

        let dropdown = app.buttons["Baby icon, Select Baby, Menu dropdown"]
        dropdown.tap()

        let addNewBaby = app.buttons["Add New Baby"]
        XCTAssertTrue(addNewBaby.waitForExistence(timeout: 2), "Add New Baby button not found.")
        addNewBaby.tap()

        let nameField = app.textFields["Baby's Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2), "Baby's Name field not found.")
        nameField.tap()
        nameField.typeText(name)

        // Set a date in the past to satisfy any constraints
        let datePickersQuery = app.datePickers.firstMatch
        datePickersQuery.tap()
        // Just pick day "1" to ensure valid date
        app.staticTexts["1"].tap()
        // Dismiss the date picker popover
        app.buttons["PopoverDismissRegion"].tap()

        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled with valid baby data.")
        saveButton.tap()

        // Return to main or feed screen if needed
        // app.buttons["Dashboard"].tap()
    }

    // MARK: - Tests

    /// Tests the scenario where there are no babies in the system, so "No babies found" should appear in AddEntryView.
    func testNoBabiesFoundFlow() throws {
        let app = XCUIApplication()
        app.launch()
        deleteAllBabies(app)

        // Navigate to AddEntryView if needed; for example:
        // If you have a tab bar or a button that takes you there, adapt to your UI.
        // Suppose we have a tab named "Add Entry" for direct testing:
        app.buttons["Add Entry"].tap()

        // Debug print for diagnosing element-finding issues
        print("DEBUG: Current UI after tapping 'Add Entry':\n\(app.debugDescription)")

        // Check that "No babies found" is displayed
        XCTAssertTrue(
            app.staticTexts["No babies found"].waitForExistence(timeout: 5),
            "Should show 'No babies found' message if there are no babies."
        )
        XCTAssertTrue(app.staticTexts["Please add a baby in Settings before adding entries."].waitForExistence(timeout: 5))
    }

    /// Tests adding a weight entry in kilograms.
    func testAddWeightInKilograms() throws {
        let app = XCUIApplication()
        app.launch()

        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Debug print
        print("DEBUG: Current UI for 'AddEntryView':\n\(app.debugDescription)")

        // Tap the "Weight" button
        let weightButton = app.buttons["Weight"]
        XCTAssertTrue(weightButton.waitForExistence(timeout: 2), "Weight button not found.")
        weightButton.tap()

        // Verify that the Kilograms text field is present
        let kilogramsField = app.textFields["Kilograms"]
        XCTAssertTrue(
            kilogramsField.waitForExistence(timeout: 2),
            "Kilograms text field not found after tapping Weight."
        )
        // Confirm the unit toggle is on "Kilograms" by default or set it if needed
        XCTAssertTrue(app.buttons["Kilograms"].isSelected, "Kilograms should be selected.")

        // Enter a valid weight
        kilogramsField.tap()
        kilogramsField.typeText("3.5")

        // Debug to ensure we typed the correct value
        print("DEBUG: Entered weight in kg: \(kilogramsField.value ?? "")")

        // Tap Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled, "Confirm should be enabled with valid kg weight.")
        confirmButton.tap()

        // Verify success banner
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests adding a weight entry in pounds and ounces.
    func testAddWeightInPoundsOunces() throws {
        let app = XCUIApplication()
        app.launch()

        // Create a baby
        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap the "Weight" button
        let weightButton = app.buttons["Weight"]
        XCTAssertTrue(weightButton.waitForExistence(timeout: 2))
        weightButton.tap()

        // Switch the picker to "Pounds & Ounces"
        app.buttons["Pounds & Ounces"].tap()

        print("DEBUG: Current UI for 'AddEntryView':\n\(app.debugDescription)")

        // Fill in pounds and ounces
        let poundsField = app.textFields["Pounds"]
       
        XCTAssertTrue(poundsField.waitForExistence(timeout: 2), "Pounds text field not found.")

        poundsField.tap()
        poundsField.typeText("7")
        
        let ouncesField = app.textFields["Ounces"]
        XCTAssertTrue(ouncesField.waitForExistence(timeout: 2), "Ounces text field not found.")
        ouncesField.tap()
        ouncesField.typeText("5.5")

        print(
            "DEBUG: Entered weight in lb/oz: \(poundsField.value ?? "") lb, \(ouncesField.value ?? "") oz"
        )

        // Tap Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled, "Confirm should be enabled with valid lb/oz weight.")
        confirmButton.tap()

        // Verify success banner
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests feeding entry with direct breastfeeding.
    func testAddFeedingDirectBreastfeeding() throws {
        let app = XCUIApplication()
        app.launch()

        // Create a baby
        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap "Feed"
        let feedingButton = app.buttons["Feed"]
        XCTAssertTrue(feedingButton.waitForExistence(timeout: 2))
        feedingButton.tap()

        // Confirm the UI for direct breastfeeding
        XCTAssertTrue(
            app.buttons["Direct Breastfeeding"].isSelected,
            "Should default to Direct Breastfeeding, unless your code picks otherwise."
        )

        // Enter a feed time
        let feedTimeField = app.textFields["Feed time (minutes)"]
        XCTAssertTrue(
            feedTimeField.waitForExistence(timeout: 5), "Feed time text field should be present for direct breastfeeding."
        )
        feedTimeField.tap()
        feedTimeField.typeText("15")

        print("DEBUG: Entered feed time: \(feedTimeField.value ?? "") minutes")

        // Tap Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled, "Confirm should be enabled with valid feed time.")
        confirmButton.tap()

        // Verify success
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests feeding entry with a bottle (volume in mL, milk type).
    func testAddFeedingBottle() throws {
        let app = XCUIApplication()
        app.launch()

        // Create a baby
        // createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap "Feed"
        let feedingButton = app.buttons["Feed"]
        XCTAssertTrue(feedingButton.waitForExistence(timeout: 2))
        feedingButton.tap()

        // Switch to "Bottle"
        app.buttons["Bottle"].tap()

        // Enter bottle volume
        let volumeField = app.textFields["Bottle volume (ml)"]
        XCTAssertTrue(volumeField.waitForExistence(timeout: 2))
        volumeField.tap()
        volumeField.typeText("60")

        print("DEBUG: Entered bottle volume: \(volumeField.value ?? "") ml")

        // Pick milk type if you want to switch from default
        app.buttons["Formula"].tap()

        // Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        // Success
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests adding a wet diaper (void) entry.
    func testAddWetDiaper() throws {
        let app = XCUIApplication()
        app.launch()

        // Create baby
        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap "Void"
        let voidButton = app.buttons["Void"]
        XCTAssertTrue(voidButton.waitForExistence(timeout: 2))
        voidButton.tap()

        // Pick volume
        app.buttons["Medium"].tap()

        // Pick color
        app.buttons["Red"].tap()

        print("DEBUG: Selected wet diaper volume = Medium, color = Red")

        // Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        // Success
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests adding a stool entry.
    func testAddStool() throws {
        let app = XCUIApplication()
        app.launch()

        // Create baby
        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap "Stool"
        let stoolButton = app.buttons["Stool"]
        XCTAssertTrue(stoolButton.waitForExistence(timeout: 2))
        stoolButton.tap()

        // Select volume
        app.buttons["Heavy"].tap()

        // Select color
        app.buttons["Green"].tap()

        print("DEBUG: Selected stool volume = Heavy, color = Green")

        // Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        // Success
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests adding a dehydration entry (toggle fields).
    func testAddDehydration() throws {
        let app = XCUIApplication()
        app.launch()

        // Create baby
        //        createTestBaby(app)

        // Navigate to AddEntryView
        app.buttons["Add Entry"].tap()

        // Tap "Dehydration"
        let dehydrationButton = app.buttons["Dehydration"]
        XCTAssertTrue(dehydrationButton.waitForExistence(timeout: 2))
        dehydrationButton.tap()

        // Toggle poor skin elasticity
        let poorSkinSwitch = app.switches["Poor Skin Elasticity"]
        XCTAssertTrue(poorSkinSwitch.waitForExistence(timeout: 5), "Poor Skin Elasticity toggle not found.")
        poorSkinSwitch.tap()

        // Toggle dry mucous membranes
        let dryMucousSwitch = app.switches["Dry Mucous Membranes"]
        XCTAssertTrue(dryMucousSwitch.waitForExistence(timeout: 5), "Dry Mucous Membranes toggle not found.")
        dryMucousSwitch.tap()

        print("DEBUG: Dehydration toggles set on")

        // Confirm
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        // Success
        // let successBanner = app.staticTexts["Entry saved successfully!"]
        // XCTAssertTrue(successBanner.waitForExistence(timeout: 3))
    }

    /// Tests that invalid weight inputs show an error or keep the Confirm button disabled.
    func testInvalidWeightEntry() throws {
        let app = XCUIApplication()
        app.launch()

        // Create baby
        //        createTestBaby(app)

        // Go to Add Entry
        app.buttons["Add Entry"].tap()

        // Tap "Weight"
        app.buttons["Weight"].tap()

        // By default, let's assume it’s “Kilograms”. Leave it blank or enter invalid data.
        let kgField = app.textFields["Kilograms"]
        kgField.tap()
        kgField.typeText("-1")  // Invalid negative value

        print("DEBUG: Entered invalid kg weight: \(kgField.value ?? "")")

        // Confirm button should either be disabled or show a local error message
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(
            !confirmButton.isEnabled,
            "Button not enabled"
        )

        // Tap confirm
        confirmButton.tap()

        // Because the code logic for weight says: if negative => formCheck returns an error => We expect to see a red error text.
        let errorLabel = app.staticTexts["Invalid weight (kg) value."]
        XCTAssertTrue(
            errorLabel.waitForExistence(timeout: 2),
            "Should show an error label for invalid weight input."
        )

        // At this point, the entry won't be saved, so "Entry saved successfully!" should NOT appear
        let successBanner = app.staticTexts["Entry saved successfully!"]
        XCTAssertFalse(successBanner.waitForExistence(timeout: 5), "Success banner should not appear with invalid input.")
    }

    /// Tests that invalid feeding input (zero or negative time or volume) is handled properly.
    func testInvalidFeedingInput() throws {
        let app = XCUIApplication()
        app.launch()

        // Create baby
        //        createTestBaby(app)

        // Go to Add Entry
        app.buttons["Add Entry"].tap()

        // Tap "Feed"
        app.buttons["Feed"].tap()

        // Direct breastfeeding is default
        let minutesField = app.textFields["Feed time (minutes)"]
        minutesField.tap()
        minutesField.typeText("0")  // Invalid

        print("DEBUG: Entered invalid feed time: \(minutesField.value ?? "") minutes")

        // The formCheck would return error for 0 => "Invalid feed time (minutes)."
        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(!confirmButton.isEnabled, "Button should not be enabled")

        confirmButton.tap()

        // Wait for error
        let errorLabel = app.staticTexts["Invalid feed time (minutes)."]
        XCTAssertTrue(
            errorLabel.waitForExistence(timeout: 2), "Should show an error label for invalid feed time."
        )

        let successBanner = app.staticTexts["Entry saved successfully!"]
        XCTAssertFalse(
            successBanner.waitForExistence(timeout: 5), "Success banner should not appear with invalid feeding data."
        )
    }
}

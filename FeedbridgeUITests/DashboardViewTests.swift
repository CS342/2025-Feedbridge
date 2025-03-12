//
//  DahsboardViewTests.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/11/25.
//

import XCTest

class DashboardViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "Feedbridge")
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
        let dropdown = app.buttons["Baby icon, Select Baby, Menu dropdown"]
        dropdown.tap()
        let addNew = app.buttons["Add New Baby"]
        XCTAssertTrue(addNew.exists, "Should be displayed")
        addNew.tap()
        
        
        // ADD FORM LOGIC
        XCTAssertFalse(app.buttons["Save"].isEnabled, "Button should be disabled")
        let nameField = app.textFields["Baby's Name"]
        nameField.tap()
        nameField.typeText("Benjamin")
        
        //Date Pickers
        let datePickersQuery = app.datePickers.firstMatch
        datePickersQuery.tap()
        app.staticTexts["1"].tap()
        app.staticTexts["March 2025"].tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "March")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2025")
        app.buttons["PopoverDismissRegion"].tap()
        
        app.buttons["Save"].tap()
        
        //        XCTAssertTrue(app.staticTexts["Benjamin"].isEmpty, "Should not be displayed")
        
        XCTAssertTrue(app.buttons["HealthDetails"].exists, "Should be displayed")
        XCTAssertTrue(app.buttons["Baby icon, Benjamin, Menu dropdown"].exists, "Should be displayed")
        XCTAssertTrue(app.buttons["Delete Baby, Delete Baby"].exists, "Should be displayed")
        
        XCTAssertTrue(app.staticTexts["Benjamin"].exists, "Should be displayed")
        XCTAssertTrue(app.staticTexts["Use Kilograms"].exists, "Should be displayed")
        
    }
}

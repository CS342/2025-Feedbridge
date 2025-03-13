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
    
    func testStoolNavExists() {
        let app = XCUIApplication()
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()
        let nav = app.staticTexts["Stools"]
        XCTAssertTrue(nav.exists, "Stool navigation should exist")
    }
    
    func testStoolEntries() {
        let app = XCUIApplication()
        app.buttons["Settings"].tap()
        app.buttons["Dashboard"].tap()
        let nav = app.buttons["Stool Drop, Stools, Next page, Medium and Brown"]
        XCTAssertTrue(nav.exists, "Stool navigation should exist")
        XCTAssertTrue(app.staticTexts["Stools"].exists, "Stool title should exist")
        XCTAssertTrue(app.staticTexts["Medium and Brown"].exists, "Stool title should exist")
    }
}

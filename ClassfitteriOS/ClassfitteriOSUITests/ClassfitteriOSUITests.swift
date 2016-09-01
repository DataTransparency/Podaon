//
//  ClassfitteriOSUITests.swift
//  ClassfitteriOSUITests
//
//  Created by James Wood on 7/7/16.
//  Copyright © 2016 James Wood. All rights reserved.
//

import XCTest

class ClassfitteriOSUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicNavigation() {
        let app = XCUIApplication()
        app.buttons["Enter"].tap()
        app.buttons["Send"].tap()
        let doneButton = app.buttons["Done"]
        doneButton.tap()
        doneButton.tap()
        app.navigationBars["Locker room"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }

}

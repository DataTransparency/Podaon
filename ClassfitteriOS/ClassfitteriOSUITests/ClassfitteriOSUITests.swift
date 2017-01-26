//
//  ClassfitteriOSUITests.swift
//  ClassfitteriOSUITests
//
//  Created by James Wood on 7/7/16.
//  Copyright © 2016 James Wood. All rights reserved.
//

import XCTest
import PromiseKit
let systemAlertHandlerDescription = "systemAlertHandlerDescription"

class ClassfitteriOSUITests: XCTestCase {
    var systemAlertMonitorToken: NSObjectProtocol? = nil
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        
        systemAlertMonitorToken = addUIInterruptionMonitor(withDescription: systemAlertHandlerDescription) { (alert) -> Bool in
            sleep(5)
            if alert.buttons.matching(identifier: "OK").count > 0 {
                alert.buttons["OK"].tap()
                sleep(5)
                return true
            } else {
                return false
            }
        }

    }

    override func tearDown() {
        if let systemAlertMonitorToken = self.systemAlertMonitorToken {
            removeUIInterruptionMonitor(systemAlertMonitorToken)
        }
        
        super.tearDown()
    }

    func testBasicNavigation() {
        XCUIDevice.shared().orientation = .portrait
        let app = XCUIApplication()
        app.tabBars.buttons["Workout"].tap()
        app.buttons["Sign out"].tap()
        app.buttons["Enter"].tap()
        let txtfirstnameTextField = app.textFields["txtFirstName"]
        txtfirstnameTextField.tap()
        txtfirstnameTextField.typeText("James")
        let txtsurnameTextField = app.textFields["txtSurname"]
        txtsurnameTextField.tap()
        txtsurnameTextField.typeText("Wood")
        app.buttons["Next"].tap()
        let txtNewMessage = app.textFields["txtNewMessage"]
        txtNewMessage.tap()
        txtNewMessage.typeText("Hello World")
        app.buttons["Send"].tap()
        app.navigationBars["Locker room"].buttons["Start"].tap()
        let doneButton = app.buttons["Done"]
        doneButton.tap()
        doneButton.tap()
        app.navigationBars["Locker room"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }
}

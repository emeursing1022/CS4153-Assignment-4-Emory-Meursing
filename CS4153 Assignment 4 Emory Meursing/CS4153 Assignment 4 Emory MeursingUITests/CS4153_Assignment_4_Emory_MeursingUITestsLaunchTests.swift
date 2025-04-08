//
//  CS4153_Assignment_4_Emory_MeursingUITestsLaunchTests.swift
//  CS4153 Assignment 4 Emory MeursingUITests
//
//  Created by Sarah Luster on 4/7/25.
//

import XCTest

final class CS4153_Assignment_4_Emory_MeursingUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

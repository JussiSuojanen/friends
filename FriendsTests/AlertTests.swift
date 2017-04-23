//
//  AlertTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 23/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest

class AlertTests: XCTestCase {
    
    func testAlert() {
        let expectAlertActionHandlerCall = expectation(description: "Alert action handler called")

        let alert = SingleButtonAlert(
            title: "",
            message: "",
            action: AlertAction(buttonTitle: "", handler: {
                expectAlertActionHandlerCall.fulfill()
            })
        )

        alert.action.handler!()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

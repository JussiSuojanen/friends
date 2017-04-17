//
//  FriendsTests.swift
//  FriendsTests
//
//  Created by Jussi Suojanen on 07/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import XCTest

class FriendsTests: XCTestCase {

    func testSuccessfulInit() {
        let testSuccessfulJSON: JSON = ["id": 1,
                                    "firstname": "Jimmy",
                                    "lastname": "Swifty",
                                    "phonenumber": "0501234567"]

        XCTAssertNotNil(Friend(json: testSuccessfulJSON))
    }

    func testFailInit() {
        let testFailJSON: JSON = ["id": 1,
                                    "firstnamee": "Jimmy",
                                    "lastnamee": "Swifty",
                                    "phonenumbere": "0501234567"]

        XCTAssertNil(Friend(json: testFailJSON))
    }
}

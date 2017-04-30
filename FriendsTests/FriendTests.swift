//
//  FriendTests.swift
//  FriendTests
//
//  Created by Jussi Suojanen on 07/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import XCTest

class FriendTests: XCTestCase {

    func testSuccessfulInit() {
        let testSuccessfulJSON: JSON = ["id": 1,
                                    "firstname": "Jimmy",
                                    "lastname": "Swifty",
                                    "phonenumber": "0501234567"]

        XCTAssertNotNil(Friend(json: testSuccessfulJSON))
    }
}

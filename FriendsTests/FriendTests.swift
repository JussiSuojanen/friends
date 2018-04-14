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

// Mark: - extension Friend
private extension Friend {
    init?(json: JSON) {
        guard let id = json["id"] as? Int,
            let firstname = json["firstname"] as? String,
            let lastname = json["lastname"] as? String,
            let phonenumber = json["phonenumber"] as? String else {
                return nil
        }
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.phonenumber = phonenumber
    }
}

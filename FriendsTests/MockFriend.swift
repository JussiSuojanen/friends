//
//  MockFriend.swift
//  Friends
//
//  Created by Jussi Suojanen on 17/04/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import Foundation

extension Friend {
    static func with(id: Int = 0,
                     firstname: String = "Jimmy",
                     lastname: String = "Swift",
                     phonenumber: String = "0501234567" ) -> Friend
    {
        return Friend(firstname: firstname,
                       lastname: lastname,
                       phonenumber: phonenumber,
                       id: id)
    }
}

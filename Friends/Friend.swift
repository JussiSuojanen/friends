//
//  friend.swift
//  Friends
//
//  Created by Jussi Suojanen on 09/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

struct Friend {
    let firstname: String
    let lastname: String
    let phonenumber: String
    let id: Int
}

/// Mark: - extension Friend
/// Put init functions inside extension so default constructor
/// for the struct is created
extension Friend {
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

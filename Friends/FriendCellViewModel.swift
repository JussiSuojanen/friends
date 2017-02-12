//
//  FriendCellViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 11/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

protocol FriendCellViewModel {
    var friendItem: Friend { get }
    var fullName: String { get }
    var phonenumberText: String { get }
}

extension Friend: FriendCellViewModel {
    var friendItem: Friend {
        return self
    }
    var fullName: String {
        return firstname + " " + lastname
    }
    var phonenumberText: String {
        return phonenumber
    }
}

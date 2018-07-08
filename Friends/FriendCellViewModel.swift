//
//  FriendCellViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 11/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

struct FriendCellViewModel {
    let firstname: String
    let lastname: String
    let phonenumber: String
    let id: Int
}

extension FriendCellViewModel {
    init(friend: Friend) {
        self.firstname = friend.firstname
        self.lastname = friend.lastname
        self.phonenumber = friend.phonenumber
        self.id = friend.id
    }
}

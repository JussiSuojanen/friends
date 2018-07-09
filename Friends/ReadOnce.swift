//
//  ReadOnce.swift
//  Friends
//
//  Created by Jussi Suojanen on 08/07/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

class ReadOnce<Value> {
    var isRead: Bool {
        return value == nil
    }

    private var value: Value?

    init(_ value: Value?) {
        self.value = value
    }

    func read() -> Value? {
        defer { value = nil }

        if value != nil {
            return value
        }

        return nil
    }
}

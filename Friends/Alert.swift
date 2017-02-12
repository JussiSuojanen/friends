//
//  Alert.swift
//  Friends
//
//  Created by Jussi Suojanen on 09/01/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//
import UIKit

struct AlertAction {
    let buttonTitle: String
    let handler: (() -> Void)?
}

struct SingleButtonAlert {
    let title: String
    let message: String?
    let action: AlertAction
}

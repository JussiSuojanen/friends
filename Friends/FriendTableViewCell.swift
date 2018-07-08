//
//  FriendTableViewCell.swift
//  Friends
//
//  Created by Jussi Suojanen on 11/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelPhoneNumber: UILabel!

    var viewModel: FriendCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    private func bindViewModel() {
        if let viewModel = viewModel {
            labelFullName?.text = "\(viewModel.firstname) \(viewModel.lastname)"
            labelPhoneNumber?.text = viewModel.phonenumber
        }
    }
}


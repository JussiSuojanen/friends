//
//  FriendViewController.swift
//  Friends
//
//  Created by Jussi Suojanen on 06/01/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit
import PKHUD

final class FriendViewController: UIViewController {
    @IBOutlet weak var textFieldFirstname: UITextField! {
        didSet {
            textFieldFirstname.delegate = self
            textFieldFirstname.addTarget(self, action:
                #selector(firstnameTextFieldDidChange),
                                         for: .editingChanged)
        }
    }
    @IBOutlet weak var textFieldLastname: UITextField! {
        didSet {
            textFieldLastname.delegate = self
            textFieldLastname.addTarget(self, action:
                #selector(lastnameTextFieldDidChange),
                                         for: .editingChanged)
        }
    }
    @IBOutlet weak var textFieldPhoneNumber: UITextField! {
        didSet {
            textFieldPhoneNumber.delegate = self
            textFieldPhoneNumber.addTarget(self, action:
                #selector(phoneNumberTextFieldDidChange),
                                        for: .editingChanged)
        }
    }

    @IBOutlet weak var buttonSubmit: UIButton!

    var updateFriends: (() -> Void)?
    var viewModel: FriendViewModel?

    fileprivate var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    func firstnameTextFieldDidChange(textField: UITextField){
        viewModel?.firstname = textField.text ?? ""
    }

    func lastnameTextFieldDidChange(textField: UITextField){
        viewModel?.lastname = textField.text ?? ""
    }

    func phoneNumberTextFieldDidChange(textField: UITextField){
        viewModel?.phonenumber = textField.text ?? ""
    }

    func bindViewModel() {
        title = viewModel?.title
        textFieldFirstname?.text = viewModel?.firstname ?? ""
        textFieldLastname?.text = viewModel?.lastname ?? ""
        textFieldPhoneNumber?.text = viewModel?.phonenumber ?? ""

        viewModel?.showLoadingHud.bind {
            PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
            $0 ? PKHUD.sharedHUD.show() : PKHUD.sharedHUD.hide()
        }

        viewModel?.updateSubmitButtonState = { [weak self] state in
            self?.buttonSubmit?.isEnabled = state
        }

        viewModel?.navigateBack = { [weak self] in
            self?.updateFriends?()
            let _ = self?.navigationController?.popViewController(animated: true)
        }

        viewModel?.onShowError = { [weak self] alert in
            self?.presentSingleButtonDialog(alert: alert)
        }
    }
}

// MARK: - Actions
extension FriendViewController {
    @IBAction func rootViewTapped(_ sender: Any) {
        activeTextField?.resignFirstResponder()
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        viewModel?.submitFriend()
    }
}

// MARK: - UITextFieldDelegate
extension FriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}

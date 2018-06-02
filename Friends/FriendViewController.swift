//
//  FriendViewController.swift
//  Friends
//
//  Created by Jussi Suojanen on 06/01/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxSwiftExt

final class FriendViewController: UIViewController {
    @IBOutlet weak var textFieldFirstname: UITextField!
    @IBOutlet weak var textFieldLastname: UITextField!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!

    @IBOutlet weak var buttonSubmit: UIButton!

    var viewModel: FriendViewModel?
    var updateFriends = PublishSubject<Void>()

    fileprivate var activeTextField: UITextField?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateFriends.onCompleted()

        super.viewWillDisappear(animated)
    }

    func bindViewModel() {
        guard var viewModel = viewModel else {
            return
        }

        title = viewModel.title.value

        bind(textField: textFieldFirstname, to: viewModel.firstname)
        bind(textField: textFieldLastname, to: viewModel.lastname)
        bind(textField: textFieldPhoneNumber, to: viewModel.phonenumber)

        viewModel.submitButtonEnabled
        .bind(to: buttonSubmit.rx.isEnabled)
        .disposed(by: disposeBag)

        buttonSubmit.rx.tap.asObservable()
            .bind(to: viewModel.submitButtonTapped)
            .disposed(by: disposeBag)

        viewModel.showLoadingHud.asObservable().subscribe(
            onNext: { [weak self] visible in
                self?.setLoadingHud(visible: visible)
            },
            onError: { [weak self] _ in
                self?.setLoadingHud(visible: false)
            },
            onCompleted: { [weak self] in
                self?.setLoadingHud(visible: false)
            }
        ).disposed(by: disposeBag)

        viewModel.navigateBack.asObservable().subscribe(
                onNext: { [weak self] in
                self?.updateFriends.onNext(())
                let _ = self?.navigationController?.popViewController(animated: true)
            }
        ).disposed(by: disposeBag)

        viewModel.onShowError.asObservable().subscribe(
            onNext: { [weak self] alert in
                if let alert = alert {
                    self?.presentSingleButtonDialog(alert: alert)
                }
            }
        ).disposed(by: disposeBag)
    }

    private func bind(textField: UITextField, to variable: Variable<String>) {
        variable.asObservable()
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        textField.rx.text.unwrap()
            .bind(to: variable)
            .disposed(by: disposeBag)
    }

    private func setLoadingHud(visible: Bool) {
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        visible ? PKHUD.sharedHUD.show(onView: view) : PKHUD.sharedHUD.hide()
    }
}

// MARK: - Actions
extension FriendViewController {
    @IBAction func rootViewTapped(_ sender: Any) {
        activeTextField?.resignFirstResponder()
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

extension FriendViewController: SingleButtonDialogPresenter { }

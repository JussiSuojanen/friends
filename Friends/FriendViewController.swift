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
import RxCocoa

final class FriendViewController: UIViewController {
    @IBOutlet weak var textFieldFirstname: UITextField!
    @IBOutlet weak var textFieldLastname: UITextField!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    @IBOutlet weak var buttonSubmit: UIButton!

    var viewModel: FriendViewModel?
    var updateFriends = PublishSubject<Void>()

    let disposeBag = DisposeBag()

    private var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateFriends.onCompleted()

        super.viewWillDisappear(animated)
    }

    func bindViewModel() {
        guard let viewModel = viewModel else {
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

        viewModel
            .onShowLoadingHud
            .asObservable()
            .map { [weak self] in self?.setLoadingHud(visible: $0) }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel
            .onNavigateBack
            .asObservable()
            .subscribe(
                onNext: { [weak self] in
                    self?.updateFriends.onNext(())
                    let _ = self?.navigationController?.popViewController(animated: true)
                }
            ).disposed(by: disposeBag)

        viewModel
            .onShowError
            .map { [weak self] in self?.presentSingleButtonDialog(alert: $0)}
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bind(textField: UITextField, to behaviorRelay: BehaviorRelay<String>) {
        behaviorRelay.asObservable()
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        textField.rx.text.unwrap()
            .bind(to: behaviorRelay)
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

//
//  AddFriendViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 06/01/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import RxSwift

protocol FriendViewModel {
    var title: Variable<String> { get }
    var firstname: Variable<String> { get }
    var lastname: Variable<String> { get }
    var phonenumber: Variable<String> { get }
    var submitButtonTapped: PublishSubject<Void> { get }
    var onShowLoadingHud: Observable<Bool> { get }
    var submitButtonEnabled: Observable<Bool> { get }
    var onNavigateBack: PublishSubject<Void>  { get }
    var onShowError: PublishSubject<SingleButtonAlert>  { get }
}

final class AddFriendViewModel: FriendViewModel {
    let onNavigateBack = PublishSubject<Void>()
    let onShowError = PublishSubject<SingleButtonAlert>()
    let submitButtonTapped = PublishSubject<Void>()

    var title = Variable<String>("Add Friend")
    var firstname = Variable<String>("")
    var lastname = Variable<String>("")
    var phonenumber = Variable<String>("")
    var onShowLoadingHud: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }

    var submitButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(firstnameValid, lastnameValid, phoneNumberValid) { $0 && $1 && $2 }
    }

    private let loadInProgress = Variable<Bool>(false)
    private let appServerClient: AppServerClient
    private let disposeBag = DisposeBag()

    private var firstnameValid: Observable<Bool> {
        return firstname.asObservable().map { $0.count > 0 }
    }
    private var lastnameValid: Observable<Bool> {
        return lastname.asObservable().map { $0.count > 0 }
    }
    private var phoneNumberValid: Observable<Bool> {
        return phonenumber.asObservable().map { $0.count > 0 }
    }

    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient

        submitButtonTapped
            .subscribe(
                onNext: { [weak self] in
                    self?.postFriend()
                }
            )
            .disposed(by: disposeBag)
    }

    private func postFriend() {
        loadInProgress.value = true
        appServerClient.postFriend(
            firstname: firstname.value,
            lastname: lastname.value,
            phonenumber: phonenumber.value)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.loadInProgress.value = false
                    self?.onNavigateBack.onNext(())
                },
                onError: { [weak self] error in
                    guard let `self` = self else {
                        return
                    }

                    self.loadInProgress.value = false

                    let okAlert = SingleButtonAlert(
                        title: (error as? AppServerClient.PostFriendFailureReason)?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                        message: "Could not add \(self.firstname.value) \(self.lastname.value).",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )

                    self.onShowError.onNext(okAlert)
                }
            )
            .disposed(by: disposeBag)
    }
}

private extension AppServerClient.PostFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to add friends friends."
        case .notFound:
            return "Failed to add friend. Please try again."
        }
    }
}

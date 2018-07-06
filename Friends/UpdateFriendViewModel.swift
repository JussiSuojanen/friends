//
//  UpdateFriendViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 08/02/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//
import RxSwift

final class UpdateFriendViewModel: FriendViewModel {
    let onShowError = PublishSubject<SingleButtonAlert>()

    var title = Variable<String>("Update Friend")
    var firstname = Variable<String>("")
    var lastname = Variable<String>("")
    var phonenumber = Variable<String>("")
    var submitButtonEnabled = Observable.just(false)
    var navigateBack = PublishSubject<Void>()

    private let friend: Friend

    private var firstnameValid: Observable<Bool> {
        return firstname.asObservable().map { $0.count > 0 }
    }

    private var lastnameValid: Observable<Bool> {
        return lastname.asObservable().map { $0.count > 0 }
    }

    private var phoneNumberValid: Observable<Bool> {
        return phonenumber.asObservable().map { $0.count > 0 }
    }

    let submitButtonTapped = PublishSubject<Void>()
    let showLoadingHud = Variable(false)
    let disposeBag = DisposeBag()

    private let appServerClient: AppServerClient

    init(friend: Friend, appServerClient: AppServerClient = AppServerClient()) {
        self.friend = friend
        self.firstname.value = friend.firstname
        self.lastname.value = friend.lastname
        self.phonenumber.value = friend.phonenumber
        self.appServerClient = appServerClient
        self.submitButtonEnabled = Observable.combineLatest(firstnameValid, lastnameValid, phoneNumberValid) { $0 && $1 && $2 }

        self.submitButtonTapped.asObserver()
            .subscribe(onNext: { [weak self] in
                self?.submitFriend()
                }
        ).disposed(by: disposeBag)
    }

    private func submitFriend() {
        showLoadingHud.value = true

        appServerClient.patchFriend(
            firstname: firstname.value,
            lastname: lastname.value,
            phonenumber: phonenumber.value,
            id: friend.id)
            .subscribe(
                onNext: { [weak self] friend in
                    self?.showLoadingHud.value = false
                    self?.navigateBack.onNext(())
                },
                onError: { [weak self] error in
                    self?.showLoadingHud.value = false
                    let okAlert = SingleButtonAlert(
                        title: (error as? AppServerClient.PatchFriendFailureReason)?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                        message: "Failed to update information.",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )

                    self?.onShowError.onNext(okAlert)
                }
            )
            .disposed(by: disposeBag)
    }
}

fileprivate extension AppServerClient.PatchFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to update friends friends."
        case .notFound:
            return "Failed to update friend. Please try again."
        }
    }
}

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
    let onNavigateBack = PublishSubject<Void>()
    let submitButtonTapped = PublishSubject<Void>()
    let disposeBag = DisposeBag()

    var title = Variable<String>("Update Friend")
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

    private let loadInProgress = Variable(false)
    private let appServerClient: AppServerClient
    private let friendId: Int

    private var firstnameValid: Observable<Bool> {
        return firstname.asObservable().map { $0.count > 0 }
    }
    private var lastnameValid: Observable<Bool> {
        return lastname.asObservable().map { $0.count > 0 }
    }
    private var phoneNumberValid: Observable<Bool> {
        return phonenumber.asObservable().map { $0.count > 0 }
    }

    init(friendCellViewModel: FriendCellViewModel, appServerClient: AppServerClient = AppServerClient()) {
        self.firstname.value = friendCellViewModel.firstname
        self.lastname.value = friendCellViewModel.lastname
        self.phonenumber.value = friendCellViewModel.phonenumber
        self.friendId = friendCellViewModel.id
        self.appServerClient = appServerClient

        self.submitButtonTapped.asObserver()
            .subscribe(onNext: { [weak self] in
                self?.submitFriend()
                }
        ).disposed(by: disposeBag)
    }

    private func submitFriend() {
        loadInProgress.value = true

        appServerClient.patchFriend(
            firstname: firstname.value,
            lastname: lastname.value,
            phonenumber: phonenumber.value,
            id: friendId)
            .subscribe(
                onNext: { [weak self] friend in
                    self?.loadInProgress.value = false
                    self?.onNavigateBack.onNext(())
                },
                onError: { [weak self] error in
                    self?.loadInProgress.value = false
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

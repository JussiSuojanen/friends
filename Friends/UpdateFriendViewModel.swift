//
//  UpdateFriendViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 08/02/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//
import RxSwift
import RxCocoa

final class UpdateFriendViewModel: FriendViewModel {
    let onShowError = PublishSubject<SingleButtonAlert>()
    let onNavigateBack = PublishSubject<Void>()
    let submitButtonTapped = PublishSubject<Void>()
    let disposeBag = DisposeBag()

    var title = BehaviorRelay<String>(value: "Update Friend")
    var firstname = BehaviorRelay<String>(value: "")
    var lastname = BehaviorRelay<String>(value: "")
    var phonenumber = BehaviorRelay<String>(value: "")
    var onShowLoadingHud: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }

    var submitButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(firstnameValid, lastnameValid, phoneNumberValid) { $0 && $1 && $2 }
    }

    private let loadInProgress = BehaviorRelay(value: false)
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
        self.firstname.accept(friendCellViewModel.firstname)
        self.lastname.accept(friendCellViewModel.lastname)
        self.phonenumber.accept(friendCellViewModel.phonenumber)
        self.friendId = friendCellViewModel.id
        self.appServerClient = appServerClient

        self.submitButtonTapped.asObserver()
            .subscribe(onNext: { [weak self] in
                self?.submitFriend()
                }
        ).disposed(by: disposeBag)
    }

    private func submitFriend() {
        loadInProgress.accept(true)

        appServerClient.patchFriend(
            firstname: firstname.value,
            lastname: lastname.value,
            phonenumber: phonenumber.value,
            id: friendId)
            .subscribe(
                onNext: { [weak self] friend in
                    self?.loadInProgress.accept(false)
                    self?.onNavigateBack.onNext(())
                },
                onError: { [weak self] error in
                    self?.loadInProgress.accept(false)
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

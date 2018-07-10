//
//  FriendsTableViewViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 11/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import RxSwift

enum FriendTableViewCellType {
    case normal(cellViewModel: FriendCellViewModel)
    case error(message: String)
    case empty
}

class FriendsTableViewViewModel {
    var friendCells: Observable<[FriendTableViewCellType]> {
        return cells.asObservable()
    }
    var onShowLoadingHud: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }

    let onShowError = PublishSubject<SingleButtonAlert>()
    let appServerClient: AppServerClient
    let disposeBag = DisposeBag()

    private let loadInProgress = Variable(false)
    private let cells = Variable<[FriendTableViewCellType]>([])

    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }

    func getFriends() {
        loadInProgress.value = true

        appServerClient
            .getFriends()
            .subscribe(
                onNext: { [weak self] friends in
                    self?.loadInProgress.value = false
                    guard friends.count > 0 else {
                        self?.cells.value = [.empty]
                        return
                    }

                    self?.cells.value = friends.compactMap { .normal(cellViewModel: FriendCellViewModel(friend: $0 )) }
                },
                onError: { [weak self] error in
                    self?.loadInProgress.value = false
                    self?.cells.value = [
                        .error(
                            message: (error as? AppServerClient.GetFriendsFailureReason)?.getErrorMessage() ?? "Loading failed, check network connection"
                        )
                    ]
                }
            )
            .disposed(by: disposeBag)
    }

    func delete(friend: FriendCellViewModel) {
        appServerClient
            .deleteFriend(id: friend.id)
            .subscribe(
                onNext: { [weak self] friends in
                    self?.getFriends()
                },
                onError: { [weak self] error in
                    let okAlert = SingleButtonAlert(
                        title: (error as? AppServerClient.DeleteFriendFailureReason)?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                        message: "Could not remove \(friend.firstname) \(friend.lastname).",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )
                    self?.onShowError.onNext(okAlert)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - AppServerClient.GetFriendsFailureReason
fileprivate extension AppServerClient.GetFriendsFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to load your friends."
        case .notFound:
            return "Could not complete request, please try again."
        }
    }
}

// MARK: - AppServerClient.DeleteFriendFailureReason
fileprivate extension AppServerClient.DeleteFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to remove friends."
        case .notFound:
            return "Friend not found."
        }
    }
}


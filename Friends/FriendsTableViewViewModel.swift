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
    var onShowError = Variable<SingleButtonAlert?>(nil)
    let showLoadingHud = Variable(false)

    var friendCells: Variable<[FriendTableViewCellType]> = Variable([])
    let appServerClient: AppServerClient
    let disposeBag = DisposeBag()

    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }

    func getFriends() {
        showLoadingHud.value = true

        appServerClient
            .getFriends()
            .subscribe(
                onNext: { [weak self] friends in
                    self?.showLoadingHud.value = false
                    guard friends.count > 0 else {
                        self?.friendCells.value = [.empty]
                        return
                    }

                    self?.friendCells.value = friends.compactMap { .normal(cellViewModel: $0 as FriendCellViewModel) }
                },
                onError: { [weak self] error in
                    self?.showLoadingHud.value = false
                    self?.friendCells.value = [
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
            .deleteFriend(id: friend.friendItem.id)
            .subscribe(
                onNext: { [weak self] friends in
                    self?.getFriends()
                },
                onError: { [weak self] error in
                    let okAlert = SingleButtonAlert(
                        title: (error as? AppServerClient.DeleteFriendFailureReason)?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                        message: "Could not remove \(friend.fullName).",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )
                    self?.onShowError.value = okAlert
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


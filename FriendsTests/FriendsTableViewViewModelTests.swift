//
//  FriendsTableViewViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 17/04/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest
import RxSwift

class FriendsTableViewViewModelTests: XCTestCase {

    // MARK: - getFriend
    func testNormalFriendCells() {
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .success(payload: [Friend.with()])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.getFriends()

        guard case .some(.normal(_)) = viewModel.friendCells.value.first else {
            XCTFail()
            return
        }
    }

    func testEmptyFriendCells() {
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .success(payload: [])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.getFriends()

        guard case .some(.empty) = viewModel.friendCells.value.first else {
            XCTFail()
            return
        }
    }

    func testErrorFriendCells() {
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .failure(AppServerClient.GetFriendsFailureReason.notFound)

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.getFriends()

        guard case .some(.error(_)) = viewModel.friendCells.value.first else {
            XCTFail()
            return
        }
    }

    // MARK: - Delete friend
    func testDeleteFriendSuccess() {
        let appServerClient = MockAppServerClient()
        appServerClient.deleteFriendResult = .success(payload: ())
        appServerClient.getFriendsResult = .success(payload: [Friend.with()])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.getFriends()

        guard case .some(.normal(_)) = viewModel.friendCells.value.first else {
            XCTFail()
            return
        }

        appServerClient.getFriendsResult = .success(payload: [])
        viewModel.delete(friend: Friend.with())

        guard case .some(.empty) = viewModel.friendCells.value.first else {
            XCTFail()
            return
        }
    }

    func testDeleteFriendFailure() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.deleteFriendResult = .failure(AppServerClient.DeleteFriendFailureReason.notFound)

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.friendCells.value = [Friend.with()].compactMap { .normal(cellViewModel: $0 as FriendCellViewModel)}

        let expectErrorShown = expectation(description: "Error note is shown")
        viewModel.onShowError.asObservable().debug().subscribe(
            onNext: { singleButtonAlert in
                if singleButtonAlert != nil {
                    expectErrorShown.fulfill()
                }
            }).disposed(by: disposeBag)

        viewModel.delete(friend: Friend.with())

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}

private final class MockAppServerClient: AppServerClient {
    var getFriendsResult: Result<[Friend], AppServerClient.GetFriendsFailureReason>?
    var deleteFriendResult: Result<Void, AppServerClient.DeleteFriendFailureReason>?

    override func getFriends() -> Observable<[Friend]> {
        return Observable.create { observer in
            switch self.getFriendsResult {
            case .success(let friends)?:
                observer.onNext(friends)
            case .failure(let error)?:
                observer.onError(error!)
            case .none:
                observer.onError(AppServerClient.GetFriendsFailureReason.notFound)
            }

            return Disposables.create()
        }
    }

    override func deleteFriend(id: Int) -> Observable<Void> {
        return Observable.create { observer in
            switch self.deleteFriendResult {
            case .success?:
                observer.onNext(())
            case .failure(let error)?:
                observer.onError(error!)
            case .none:
                observer.onError(AppServerClient.DeleteFriendFailureReason.notFound)
            }

            return Disposables.create()
        }
    }
}

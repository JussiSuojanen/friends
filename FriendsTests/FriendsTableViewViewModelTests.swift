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
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .success(payload: [Friend.with()])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)

        let expectNormalFriendCellCreated = expectation(description: "friendCells contains a normal cell")

        viewModel.friendCells.subscribe(
            onNext: {
                if case .some(.normal(_)) = $0.first {
                    expectNormalFriendCellCreated.fulfill()
                }
            }
        ).disposed(by: disposeBag)

        viewModel.getFriends()
        
        wait(for: [expectNormalFriendCellCreated], timeout: 0.1)
    }

    func testEmptyFriendCells() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .success(payload: [])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)

        let expectEmptyFriendCellCreated = expectation(description: "friendCells contains an empty cell")

        viewModel.friendCells.subscribe(
            onNext: {
                if case .some(.empty) = $0.first {
                    expectEmptyFriendCellCreated.fulfill()
                }
            }
        ).disposed(by: disposeBag)
        
        viewModel.getFriends()

        wait(for: [expectEmptyFriendCellCreated],timeout: 0.1)
    }

    func testErrorFriendCells() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.getFriendsResult = .failure(AppServerClient.GetFriendsFailureReason.notFound)

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)

        let expectErrorFriendCellCreated = expectation(description: "friendCells contains an error cell")

        viewModel.friendCells.subscribe(
            onNext: {
                if case .some(.error) = $0.first {
                    expectErrorFriendCellCreated.fulfill()
                }
            }
        ).disposed(by: disposeBag)
        
        viewModel.getFriends()

        wait(for: [expectErrorFriendCellCreated],timeout: 0.1)
    }

    // MARK: - Delete friend
    func testDeleteFriendSuccess() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        let friend = Friend.with()
        appServerClient.deleteFriendResult = .success(payload: ())
        appServerClient.getFriendsResult = .success(payload: [friend])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)

        let expectNormalFriendCellCreated = expectation(description: "friendCells contains a normal cell")

        viewModel.friendCells.subscribe(
            onNext: {
                if case .some(.normal(_)) = $0.first {
                    expectNormalFriendCellCreated.fulfill()
                }
            }
        ).disposed(by: disposeBag)

        viewModel.getFriends()

        waitForExpectations(timeout: 0.1, handler: nil)

        appServerClient.getFriendsResult = .success(payload: [])

        let expectEmptyFriendCellCreated = expectation(description: "friendCells contains no cells")

        viewModel.friendCells.subscribe(
            onNext: {
                if case .some(.empty) = $0.first {
                    expectEmptyFriendCellCreated.fulfill()
                }
            }
        ).disposed(by: disposeBag)
        
        viewModel.delete(friend: FriendCellViewModel(friend: friend))

        wait(for: [expectEmptyFriendCellCreated], timeout: 0.1)
    }

    func testDeleteFriendFailure() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        let friend = Friend.with()
        appServerClient.deleteFriendResult = .failure(AppServerClient.DeleteFriendFailureReason.notFound)

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)

        let expectErrorShown = expectation(description: "Error note is shown")
        viewModel.onShowError.subscribe(
            onNext: { singleButtonAlert in
                expectErrorShown.fulfill()
            }).disposed(by: disposeBag)

        viewModel.delete(friend: FriendCellViewModel(friend: friend))

        wait(for: [expectErrorShown], timeout: 0.1)
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

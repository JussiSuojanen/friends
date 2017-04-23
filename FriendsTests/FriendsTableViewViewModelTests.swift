//
//  FriendsTableViewViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 17/04/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest

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
        appServerClient.deleteFriendResult = .success
        appServerClient.getFriendsResult = .success(payload: [])

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.friendCells.value = [Friend.with()].flatMap { .normal(cellViewModel: $0 as FriendCellViewModel)}

        viewModel.deleteFriend(at: 0)
    }

    func testDeleteFriendFailure() {
        let appServerClient = MockAppServerClient()
        appServerClient.deleteFriendResult = .failure(AppServerClient.DeleteFriendFailureReason.notFound)

        let viewModel = FriendsTableViewViewModel(appServerClient: appServerClient)
        viewModel.friendCells.value = [Friend.with()].flatMap { .normal(cellViewModel: $0 as FriendCellViewModel)}

        let expectErrorShown = expectation(description: "Error note is shown")
        viewModel.onShowError = { _ in
            expectErrorShown.fulfill()
        }

        viewModel.deleteFriend(at: 0)

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}

private final class MockAppServerClient: AppServerClient {
    var getFriendsResult: AppServerClient.GetFriendsResult?
    var deleteFriendResult: AppServerClient.DeleteFriendResult?

    override func getFriends(completion: @escaping AppServerClient.GetFriendsCompletion) {
        completion(getFriendsResult!)
    }

    override func deleteFriend(id: Int, completion: @escaping AppServerClient.DeleteFriendCompletion) {
        completion(deleteFriendResult!)
    }
}

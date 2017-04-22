//
//  AddFriendViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest

class AddFriendViewModelTests: XCTestCase {

    func testAddFriendSuccess() {
        let appServerClient = MockAppServerClient()
        appServerClient.postFriendResult = .success

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let mockFriend = Friend.with()
        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber

        let expectNavigateCall = expectation(description: "Navigate back is called")

        viewModel.navigateBack = {
            expectNavigateCall.fulfill()
        }

        viewModel.submitFriend()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testAddFriendFailure() {
        let appServerClient = MockAppServerClient()
        appServerClient.postFriendResult = .failure(AppServerClient.PostFriendFailureReason(rawValue: 401))

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let mockFriend = Friend.with()
        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber

        let expectErrorShown = expectation(description: "OnShowError is called")

        viewModel.onShowError = { error in
            expectErrorShown.fulfill()
        }

        viewModel.submitFriend()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testValidateInputSuccess() {
        let mockFriend = Friend.with()
        let appServerClient = MockAppServerClient()

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let expectUpdateSubmitButtonStateCall = expectation(description: "updateSubmitButtonState is called")

        viewModel.updateSubmitButtonState = { state in
            XCTAssert(state == true, "testValidateInputData failed. Data should be valid")
            expectUpdateSubmitButtonStateCall.fulfill()
        }

        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber

        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

private final class MockAppServerClient: AppServerClient {
    var postFriendResult: AppServerClient.PostFriendResult?

    override func postFriend(firstname: String, lastname: String, phonenumber: String, completion: @escaping AppServerClient.PostFriendCompletion) {
        completion(postFriendResult!)
    }
}

//
//  UpdateFriendViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest

class UpdateFriendViewModelTests: XCTestCase {

    func testPatchFriendSuccess() {
        let appServerClient = MockAppServerClient()
        appServerClient.patchFriendResult = .success(payload: Friend.with())

        let viewModel = UpdateFriendViewModel(friend: Friend.with(), appServerClient: appServerClient)

        let expectNavigateCall = expectation(description: "Navigate back is called")

        viewModel.navigateBack = {
            expectNavigateCall.fulfill()
        }

        viewModel.submitFriend()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testPatchFriendFailure() {
        let appServerClient = MockAppServerClient()
        appServerClient.patchFriendResult = .failure(AppServerClient.PatchFriendFailureReason.notFound)

        let viewModel = UpdateFriendViewModel(friend: Friend.with(), appServerClient: appServerClient)

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

        let viewModel = UpdateFriendViewModel(friend: mockFriend, appServerClient: appServerClient)

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
    var patchFriendResult: AppServerClient.PatchFriendResult?

    override func patchFriend(firstname: String, lastname: String, phonenumber: String, id: Int, completion: @escaping PatchFriendCompletion) {
        completion(patchFriendResult!)
    }
}

//
//  UpdateFriendViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest
import RxSwift

class UpdateFriendViewModelTests: XCTestCase {

    func testPatchFriendSuccess() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        let friend = Friend.with()
        appServerClient.patchFriendResult = .success(payload: friend)

        let viewModel = UpdateFriendViewModel(friendCellViewModel: FriendCellViewModel(friend: friend), appServerClient: appServerClient)

        let expectNavigateCall = expectation(description: "Navigate back is called")

        viewModel.onNavigateBack.asObservable().debug().subscribe(
            onNext: { _ in
                expectNavigateCall.fulfill()
            }
        ).disposed(by: disposeBag)

        viewModel.submitButtonTapped.onNext(())

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testPatchFriendFailure() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        let friend = Friend.with()
        appServerClient.patchFriendResult = .failure(AppServerClient.PatchFriendFailureReason.notFound)

        let viewModel = UpdateFriendViewModel(friendCellViewModel: FriendCellViewModel(friend: friend), appServerClient: appServerClient)

        let expectErrorShown = expectation(description: "OnShowError is called")

        viewModel.onShowError.asObservable().subscribe(
            onNext: { singleButtonAlert in
                expectErrorShown.fulfill()
            }
        ).disposed(by: disposeBag)

        viewModel.submitButtonTapped.onNext(())

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testValidateInputSuccess() {
        let disposeBag = DisposeBag()
        let friend = Friend.with()
        let appServerClient = MockAppServerClient()

        let viewModel = UpdateFriendViewModel(friendCellViewModel: FriendCellViewModel(friend: friend), appServerClient: appServerClient)

        viewModel.firstname.value = friend.firstname
        viewModel.lastname.value = friend.lastname
        viewModel.phonenumber.value = friend.phonenumber

        let expectUpdateSubmitButtonStateCall = expectation(description: "updateSubmitButtonState is called")

        viewModel.submitButtonEnabled.subscribe(
            onNext: { state in
                XCTAssert(state == true, "testValidateInputData failed. Data should be valid")
                expectUpdateSubmitButtonStateCall.fulfill()
            }
        ).disposed(by: disposeBag)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

private final class MockAppServerClient: AppServerClient {
    var patchFriendResult: Result<Friend, AppServerClient.PatchFriendFailureReason>?

    override func patchFriend(firstname: String, lastname: String, phonenumber: String, id: Int) -> Observable<Friend> {
        return Observable.create { observer in
            switch self.patchFriendResult {
            case .success(let friend)?:
                observer.onNext(friend)
            case .failure(let error)?:
                observer.onError(error!)
            case .none:
                observer.onError(AppServerClient.GetFriendsFailureReason.notFound)
            }

            return Disposables.create()
        }
    }
}

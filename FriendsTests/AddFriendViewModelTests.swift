//
//  AddFriendViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest
import RxSwift

class AddFriendViewModelTests: XCTestCase {

    func testAddFriendSuccess() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.postFriendResult = .success(payload: ())

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let mockFriend = Friend.with()
        viewModel.firstname.value = mockFriend.firstname
        viewModel.lastname.value = mockFriend.lastname
        viewModel.phonenumber.value = mockFriend.phonenumber

        let expectNavigateCall = expectation(description: "Navigate back is called")

        viewModel.onNavigateBack.asObservable().debug().subscribe(
            onNext: { _ in
                expectNavigateCall.fulfill()
            }
        ).disposed(by: disposeBag)

        viewModel.submitButtonTapped.onNext(())

        wait(for: [expectNavigateCall], timeout: 0.1)
    }

    func testAddFriendFailure() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        appServerClient.postFriendResult = .failure(AppServerClient.PostFriendFailureReason(rawValue: 401))

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let mockFriend = Friend.with()
        viewModel.firstname.value = mockFriend.firstname
        viewModel.lastname.value = mockFriend.lastname
        viewModel.phonenumber.value = mockFriend.phonenumber

        let expectErrorShown = expectation(description: "OnShowError is called")

        viewModel.onShowError.asObservable().subscribe(
            onNext: { singleButtonAlert in
                expectErrorShown.fulfill()
            }
        ).disposed(by: disposeBag)

        viewModel.submitButtonTapped.onNext(())

        wait(for: [expectErrorShown], timeout: 0.1)
    }

    func testValidateInputSuccess() {
        let disposeBag = DisposeBag()
        let mockFriend = Friend.with()
        let appServerClient = MockAppServerClient()

        let viewModel = AddFriendViewModel(appServerClient: appServerClient)
        viewModel.firstname.value = mockFriend.firstname
        viewModel.lastname.value = mockFriend.lastname
        viewModel.phonenumber.value = mockFriend.phonenumber

        let expectUpdateSubmitButtonStateCall = expectation(description: "updateSubmitButtonState is called")

        viewModel.submitButtonEnabled.subscribe(
            onNext: { state in
                guard state else { return }

                expectUpdateSubmitButtonStateCall.fulfill()
            }
        ).disposed(by: disposeBag)

        wait(for: [expectUpdateSubmitButtonStateCall], timeout: 0.1)
    }

}

private final class MockAppServerClient: AppServerClient {
    var postFriendResult: Result<Void, AppServerClient.PostFriendFailureReason>?

    override func postFriend(firstname: String, lastname: String, phonenumber: String) -> Observable<Void> {
        return Observable.create { observer in
            switch self.postFriendResult {
            case .success?:
                observer.onNext(())
            case .failure(let error)?:
                observer.onError(error!)
            case .none:
                observer.onError(AppServerClient.GetFriendsFailureReason.notFound)
            }

            return Disposables.create()
        }
    }
}

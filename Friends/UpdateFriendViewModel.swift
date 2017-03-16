//
//  UpdateFriendViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 08/02/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

final class UpdateFriendViewModel: FriendViewModel {
    var friend: Friend
    var title: String {
        return "Update Friend"
    }
    var firstname: String? {
        didSet {
            validateInput()
        }
    }
    var lastname: String? {
        didSet {
            validateInput()
        }
    }
    var phonenumber: String? {
        didSet {
            validateInput()
        }
    }

    var validInputData: Bool = false {
        didSet {
            if oldValue != validInputData {
                updateSubmitButtonState?(validInputData)
            }
        }
    }

    var updateSubmitButtonState: ((Bool) -> ())?
    var navigateBack: (() -> ())?
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?

    let showLoadingHud = Bindable(false)
    let appServerClient = AppServerClient()

    init(friend: Friend) {
        self.friend = friend
        self.firstname = friend.firstname
        self.lastname = friend.lastname
        self.phonenumber = friend.phonenumber
    }

    func submitFriend() {
        guard let firstname = firstname,
            let lastname = lastname,
            let phonenumber = phonenumber else {
                return
        }

        updateSubmitButtonState?(false)
        showLoadingHud.value = true

        appServerClient.patchFriend(firstname: firstname, lastname: lastname, phonenumber: phonenumber, id: friend.id) { [weak self] result in

            self?.updateSubmitButtonState?(true)
            self?.showLoadingHud.value = false

            switch result {
            case .success(_):
                self?.navigateBack?()
            case .failure(let error):
                let okAlert = SingleButtonAlert(
                    title: error?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                    message: "Failed to update information.",
                    action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                )
                self?.onShowError?(okAlert)
            }
        }
    }

    func validateInput() {
        let validData = [firstname, lastname, phonenumber].filter {
            ($0?.characters.count ?? 0) < 1
        }
        validInputData = (validData.count == 0) ? true : false
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

//
//  AppServerClient.swift
//  Friends
//
//  Created by Jussi Suojanen on 07/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import Alamofire
import RxSwift

// MARK: - AppServerClient
class AppServerClient {
    // MARK: - GetFriends
    enum GetFriendsFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }

    func getFriends() -> Observable<[Friend]> {
        return Observable.create { observer -> Disposable in
            Alamofire.request("http://friendservice.herokuapp.com/listFriends")
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            // if no error provided by alamofire return .notFound error instead.
                            // .notFound should never happen here?
                            observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                            return
                        }
                        do {
                            let friends = try JSONDecoder().decode([Friend].self, from: data)
                            observer.onNext(friends)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode,
                            let reason = GetFriendsFailureReason(rawValue: statusCode)
                        {
                            observer.onError(reason)
                        }
                        observer.onError(error)
                    }
            }

            return Disposables.create()
        }
    }

    // MARK: - PostFriend
    enum PostFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }

    func postFriend(firstname: String, lastname: String, phonenumber: String) -> Observable<Void> {
        let param = ["firstname": firstname,
                     "lastname": lastname,
                     "phonenumber": phonenumber]

        return Observable<Void>.create { [param] observer -> Disposable in
            Alamofire.request("https://friendservice.herokuapp.com/addFriend", method: .post, parameters: param, encoding: JSONEncoding.default)
                .validate()
                .responseJSON { [observer] response in
                    switch response.result {
                    case .success:
                        observer.onNext(())
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode,
                            let reason = PostFriendFailureReason(rawValue: statusCode)
                        {
                            observer.onError(reason)
                        }
                        observer.onError(error)
                    }
            }

            return Disposables.create()
        }
    }

    // MARK: - PatchFriend
    enum PatchFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }

    func patchFriend(firstname: String, lastname: String, phonenumber: String, id: Int) -> Observable<Friend> {
        let param = ["firstname": firstname,
                     "lastname": lastname,
                     "phonenumber": phonenumber]
        return Observable.create { observer in
            Alamofire.request("https://friendservice.herokuapp.com/editFriend/\(id)", method: .patch, parameters: param, encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        do {
                            guard let data = response.data else {
                                // want to avoid !-mark for unwrapping. Incase there is no data and
                                // no error provided by alamofire return .notFound error instead.
                                // .notFound should never happen here?
                                observer.onError(response.error ?? GetFriendsFailureReason.notFound)

                                return
                            }

                            let friend = try JSONDecoder().decode(Friend.self, from: data)
                            observer.onNext(friend)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode,
                            let reason = PatchFriendFailureReason(rawValue: statusCode)
                        {
                            observer.onError(reason)
                        }

                        observer.onError(error)
                    }
            }

            return Disposables.create()
        }
    }

    // MARK: - DeleteFriend
    enum DeleteFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }

    func deleteFriend(id: Int) -> Observable<Void> {
        return Observable.create { observable -> Disposable in
            Alamofire.request("https://friendservice.herokuapp.com/editFriend/\(id)", method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        observable.onNext(())
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode,
                            let reason = DeleteFriendFailureReason(rawValue: statusCode)
                        {
                            observable.onError(reason)
                        }
                        observable.onError(error)
                    }
            }

            return Disposables.create()
        }
    }

}

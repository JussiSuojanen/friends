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
                        do {
                            guard let data = response.data else {
                                // want to avoid ! mark for unwrapping so incase there is no data and
                                // no error provided by alamofire return .notFound error instead.
                                // .notFound should never happen here?
                                observer.onError(response.error ?? GetFriendsFailureReason.notFound)
                                return
                            }

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

    typealias PostFriendResult = EmptyResult<PostFriendFailureReason>
    typealias PostFriendCompletion = (_ result: PostFriendResult) -> Void

    func postFriend(firstname: String, lastname: String, phonenumber: String, completion: @escaping PostFriendCompletion) {
        let param = ["firstname": firstname,
                     "lastname": lastname,
                     "phonenumber": phonenumber]
        Alamofire.request("https://friendservice.herokuapp.com/addFriend", method: .post, parameters: param, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(.success)
                case .failure(_):
                    if let statusCode = response.response?.statusCode,
                        let reason = PostFriendFailureReason(rawValue: statusCode) {
                        completion(.failure(reason))
                    }
                    completion(.failure(nil))
                }
        }
    }

    // MARK: - PatchFriend
    enum PatchFriendFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }

    typealias PatchFriendResult = Result<Friend, PatchFriendFailureReason>
    typealias PatchFriendCompletion = (_ result: PatchFriendResult) -> Void

    func patchFriend(firstname: String, lastname: String, phonenumber: String, id: Int, completion: @escaping PatchFriendCompletion) {
        let param = ["firstname": firstname,
                     "lastname": lastname,
                     "phonenumber": phonenumber]
        Alamofire.request("https://friendservice.herokuapp.com/editFriend/\(id)", method: .patch, parameters: param, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        guard let data = response.data else {
                            completion(.failure(nil))
                            return
                        }

                        let friend = try JSONDecoder().decode(Friend.self, from: data)
                        completion(.success(payload: friend))
                    } catch {
                        completion(.failure(nil))
                    }
                case .failure(_):
                    if let statusCode = response.response?.statusCode,
                        let reason = PatchFriendFailureReason(rawValue: statusCode) {
                        completion(.failure(reason))
                    }
                    completion(.failure(nil))
                }
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

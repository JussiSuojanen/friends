//
//  Result.swift
//  Friends
//
//  Created by Jussi Suojanen on 04/02/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

enum Result<T, U> where U: Error {
    case success(payload: T)
    case failure(U?)
}

enum EmptyResult<U> where U: Error {
    case success
    case failure(U?)
}

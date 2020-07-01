//
//  mapMany.swift
//  RxSwiftExt
//
//  Created by Joan Disho on 06/05/18.
//  Copyright © 2018 RxSwift Community. All rights reserved.
//

import RxSwift

extension ObservableType where Element: Collection {
    /**
     Projects each element of an observable collection into a new form.

     - parameter transform: A transform function to apply to each element of the source collection.
     - returns: An observable collection whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapMany<Result>(_ transform: @escaping (Element.Element) throws -> Result) -> Observable<[Result]> {
        return map { collection -> [Result] in
            try collection.map(transform)
        }
    }
}

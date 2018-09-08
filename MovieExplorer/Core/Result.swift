//
//  Result.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 9/8/18.
//  Copyright © 2018 Evgeny Kazakov. All rights reserved.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
  case success(Value)
  case failure(Error)
}

extension Result {
  func mapError<E>(_ map: (Error) -> E) -> Result<Value, E> {
    switch self {
    case .success(let value):
      return .success(value)
    case .failure(let error):
      return .failure(map(error))
    }
  }
}

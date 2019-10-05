//
//  ParsingError.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 9/8/18.
//  Copyright © 2018 Evgeny Kazakov. All rights reserved.
//

import Foundation

enum ParsingError: Error {
  case jsonDecoding(inner: Error)
  case noData
}

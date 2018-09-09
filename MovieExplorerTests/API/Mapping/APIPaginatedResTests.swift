//
//  APIPaginatedResTests.swift
//  MovieExplorerTests
//
//  Created by Evgeny Kazakov on 9/8/18.
//  Copyright © 2018 Evgeny Kazakov. All rights reserved.
//

import XCTest
@testable import MovieExplorer

class APIPaginatedResTests: XCTestCase {
  
  func test_ValidMoviesJSON_SuccessfullyParsed() {
    do {
      let decoder = JSONDecoder()
      let jsonData = try ResourceReader().read(named: "paginated_movies", with: "json")
      _ = try decoder.decode(APIPaginatedRes<Movie>.self, from: jsonData)
    } catch {
      XCTFail("Failed to parse movie json. \(error)")
    }
  }
  
}

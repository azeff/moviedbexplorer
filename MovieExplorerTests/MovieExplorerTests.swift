//
//  MovieExplorerTests.swift
//  MovieExplorerTests
//
//  Created by Evgeny Kazakov on 9/8/18.
//  Copyright © 2018 Evgeny Kazakov. All rights reserved.
//

import XCTest
@testable import MovieExplorer

class MovieExplorerTests: XCTestCase {
  
  func testApi() {
    let apiBaseURL = URL(string: "https://api.themoviedb.org/3")!
    let imageBase = URL(string: "https://image.tmdb.org/t/p")!
    let client = URLSessionAPIClient(apiBase: apiBaseURL, imageBase: imageBase, urlSession: URLSession.shared)
    
    let exp = expectation(description: "fetch")
    client.fetch(resource: MovieDBAPI.search(query: "batman")) { result in
      
      print(result)
      
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 30)
  }
  
}

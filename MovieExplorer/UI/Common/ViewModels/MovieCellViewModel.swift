//
//  MovieCellViewModel.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 4/10/19.
//  Copyright © 2019 Evgeny Kazakov. All rights reserved.
//

import UIKit

protocol MovieCellViewModel {
  var title: String { get }
  var overview: String? { get }
  var releaseYear: String { get }
  var image: RemoteImageViewModelProtocol? { get }
  
  func select()
}

class MovieCellViewModelImpl: MovieCellViewModel {
  
  let title: String
  let overview: String?
  let releaseYear: String
  let image: RemoteImageViewModelProtocol?
  
  private let movie: Movie
  private let apiClient: APIClient
  private let imageFetcher: ImageFetcher
  
  var onSelect: (() -> Void)?
  
  init(movie: Movie, api: APIClient, imageFetcher: ImageFetcher) {
    self.movie = movie
    self.apiClient = api
    self.imageFetcher = imageFetcher
    
    let releaseYear = movie.releaseDate.split(separator: "-").first.map(String.init) ?? ""
    title = movie.title
    overview = movie.overview
    self.releaseYear = releaseYear
    let url = movie.posterPath.map { api.posterURL(path: $0, size: .w780) }
    image = url.map { RemoteImageViewModel(url: $0, fetcher: imageFetcher) }
  }
  
  func select() {
    onSelect?()
  }
}

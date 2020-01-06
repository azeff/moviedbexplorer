//
//  RelatedMoviesViewModel.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 1/5/20.
//  Copyright © 2020 Evgeny Kazakov. All rights reserved.
//

import Foundation

enum RelatedMoviesListViewModelStatus {
  case initial
  case loading
  case loaded
  case failedToLoad
  case loadingNext
  case failedToLoadNext
}

protocol RelatedMoviesListViewModel: class {
  
  var status: RelatedMoviesListViewModelStatus { get }
  var movies: [RelatedMovieCellViewModel] { get }
  
  var onChanged: (() -> Void)? { get set }
  var onGoToDetails: ((Movie) -> Void)? { get set }

  func loadNext()
  func retry()
}

class RelatedMoviesListViewModelImpl: RelatedMoviesListViewModel {
  
  private(set) var status: RelatedMoviesListViewModelStatus = .initial
  private(set) var movies: [RelatedMovieCellViewModel] = []
  private var moviesById: [Int: RelatedMovieCellViewModel] = [:]

  var onChanged: (() -> Void)?
  var onGoToDetails: ((Movie) -> Void)?

  private let moviesList: MoviesList
  private let imageFetcher: ImageFetcher
  private var disposable: Disposable?

  init(moviesList: MoviesList, imageFetcher: ImageFetcher) {
    self.moviesList = moviesList
    self.imageFetcher = imageFetcher
    
    disposable = moviesList.store.observe(on: DispatchQueue.main) { [weak self] state in
      self?.update(with: state)
    }
  }
  
  func loadNext() {
    guard status != .failedToLoadNext else { return }
    
    moviesList.loadNext()
  }
  
  func retry() {
    moviesList.loadNext()
  }
  
  private func update(with state: MoviesListState) {
    update(movies: state)
    update(status: state)
    
    onChanged?()
  }
  
  private func update(movies state: MoviesListState) {
    var movies: [RelatedMovieCellViewModel] = []
    for movie in state.movies {
      let movieVM = moviesById[movie.id] ?? createMovieViewModel(movie)
      moviesById[movie.id] = movieVM
      movies.append(movieVM)
    }
    self.movies = movies
  }
  
  private func createMovieViewModel(_ movie: Movie) -> RelatedMovieCellViewModel {
    let vm = RelatedMovieCellViewModelImpl(movie: movie, imageFetcher: imageFetcher)
    vm.onSelect = { [weak self] in self?.onGoToDetails?(movie) }
    return vm
  }
  
  private func update(status state: MoviesListState) {
    switch state.status {
    case .notLoaded:
      status = .initial
    case .loaded:
      status = .loaded
    case .loading:
      status = state.movies.isEmpty ? .loading : .loadingNext
    case .error:
      status = state.movies.isEmpty ? .failedToLoad : .failedToLoadNext
    }
  }
  
}

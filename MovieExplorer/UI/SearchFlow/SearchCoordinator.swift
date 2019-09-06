//
//  SearchCoordinator.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 05.09.2019.
//  Copyright © 2019 Evgeny Kazakov. All rights reserved.
//

import UIKit

class SearchCoordinator: BaseCoordinator {
  
  private let navigation: UINavigationController
  private let apiClient: APIClient
  private let imageFetcher: ImageFetcher
  private let favorites: FavoriteMovies
  
  init(navigation: UINavigationController, apiClient: APIClient, imageFetcher: ImageFetcher, favorites: FavoriteMovies) {
    self.navigation = navigation
    self.apiClient = apiClient
    self.imageFetcher = imageFetcher
    self.favorites = favorites
  }
  
  override func start() {
    super.start()
    
    let recentSearchesRepository = DefaultsRecentSearchesRepository(defaults: UserDefaults.standard)
    let searchViewModel = MovieSearchViewModelImpl(
      moviesSearch: TMDBMoviesSearch(
        api: apiClient,
        recentSearchesRepository: recentSearchesRepository
      ),
      api: apiClient,
      imageFetcher: imageFetcher
    )
    
    let vc = MovieSearchVC(viewModel: searchViewModel)
    vc.goToMovieDetails = { [weak self] movie in
      self?.showDetails(movie)
    }
    navigation.viewControllers = [vc]
  }
  
  private func showDetails(_ movie: Movie) {
    let vm = MovieViewModelImpl(movie: movie, favorites: favorites, imageFetcher: imageFetcher, api: apiClient)
    let detailsVC = MovieDetailsVC(viewModel: vm)
    navigation.pushViewController(detailsVC, animated: true)
  }

}


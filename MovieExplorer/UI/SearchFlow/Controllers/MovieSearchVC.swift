//
//  FirstViewController.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 9/8/18.
//  Copyright © 2018 Evgeny Kazakov. All rights reserved.
//

import UIKit

class MovieSearchVC: UIViewController {

  var goToMovieDetails: ((Movie) -> Void)?
  
  private var viewModel: MovieSearchViewModel
  
  private let searchBar = UISearchBar()
  private lazy var contentView = MovieSearchView()
  private var moviesListView: UICollectionView {
    return contentView.moviesListView
  }
  
  private let moviesCollectionController = ListController()
  private let moviesAdapter = MoviesAdapter()
  private let recentSearchesCollectionController = ListController()
  private let recentSearchesAdapter = RecentSearchesListAdapter()
  
  private var isLoading: Bool? = false
  
  private let keyboardObserver = KeyboardObserver(notificationCenter: .default)
  
  init(viewModel: MovieSearchViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
    
    configureNavigationItem()
    
    searchBar.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureNavigationItem() {
    title = "Search"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.titleView = searchBar
  }
  
  override func loadView() {
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    configureKeyboardObserver()
    
    recentSearchesCollectionController.collectionView = contentView.recentSearchesListView
    moviesCollectionController.collectionView = contentView.moviesListView

    bind()
    update()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    keyboardObserver.startObserving()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    keyboardObserver.stopObserving()
  }
  
  private func configureKeyboardObserver() {
    keyboardObserver.onKeyboardWillShow = { [weak self] kbInfo in
      self?.contentView.recentSearchesListView.adjustContentInset(forKeyboard: kbInfo)
    }
    
    keyboardObserver.onKeyboardWillHide = { [weak self] in
      self?.contentView.recentSearchesListView.contentInset = .zero
    }
  }

  private func bind() {
    bindOutputs()
    bindInputs()
  }
  
  private func bindOutputs() {
    viewModel.onChanged = { [weak self] in
      self?.update()
    }
    viewModel.onGoToDetails = { [weak self] movie in
      self?.goToMovieDetails?(movie)
    }
  }
  
  private func bindInputs() {
    contentView.errorView.onRetry = viewModel.retry
    moviesCollectionController.onCloseToEnd = viewModel.loadNext
    moviesAdapter.onRetry = viewModel.retry
    
    recentSearchesAdapter.onSelect = { [weak self] query in
      guard let self = self else { return }
      
      self.searchBarEndEditing()
      
      self.viewModel.search(query: query)
      self.contentView.showList()
    }
  }
  
  private func update() {
    searchBar.text = viewModel.searchQuery

    updateLists()
    updateViewsVisibility()
  }
  
  func updateLists() {
    recentSearchesCollectionController.list = recentSearchesAdapter.list(from: viewModel.recentSearches)
    
    switch viewModel.status {
    case .loading:
      configureForLoading()
      
    case .loaded, .loadingNext, .failedToLoadNext:
      configureForLoaded()
      
    case .initial, .failedToLoad:
      break
    }
  }
  
  func updateViewsVisibility() {
    if searchBar.isFirstResponder {
      contentView.showLastSearches()
      return
    }

    switch viewModel.status {
    case .initial:
      contentView.showInitial()

    case .loading:
      contentView.showList()

    case .loaded, .loadingNext, .failedToLoadNext:
      if viewModel.movies.isEmpty {
        contentView.showEmpty()
      } else {
        contentView.showList()
      }

    case .failedToLoad:
      contentView.showError()
    }
  }
  
  private func configureForLoading() {
    moviesCollectionController.list = moviesAdapter.loadingList()
    
    if isLoading != true {
      isLoading = true
      moviesListView.scrollToTop()
      moviesListView.isUserInteractionEnabled = false
      moviesListView.mve.crossDissolveTransition { }
    }
  }
  
  private func configureForLoaded() {
    moviesCollectionController.list = moviesAdapter.list(movies: viewModel.movies, status: viewModel.status)
    
    if isLoading != false {
      isLoading = false
      moviesListView.scrollToTop()
      moviesListView.isUserInteractionEnabled = true
      moviesListView.mve.crossDissolveTransition { }
    }
  }
  
  private func searchBarBeginEditing() {
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  private func searchBarEndEditing() {
    searchBar.endEditing(true)
    searchBar.setShowsCancelButton(false, animated: true)
  }
}

extension MovieSearchVC: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBarBeginEditing()
    
    contentView.recentSearchesListView.scrollToTop()
    contentView.showLastSearches()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text, !query.isEmpty {
      viewModel.search(query: query)
    } else {
      viewModel.cancel()
    }
    
    searchBarEndEditing()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBarEndEditing()
    update()
  }
}

extension UIScrollView {
  func scrollToTop() {
    contentOffset = CGPoint(x: 0, y: -adjustedContentInset.top)
  }
  
  func adjustContentInset(forKeyboard keyboardInfo: KeyboardInfo) {
    guard let window = self.window else { return }
    
    let kbFrame = convert(keyboardInfo.endFrame, from: window)
    let kbHeight = bounds.intersection(kbFrame).height
    
    guard kbHeight > 0 else { return }
    
    let bottomInset = kbHeight - safeAreaInsets.bottom
    contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    scrollIndicatorInsets = contentInset
  }
}

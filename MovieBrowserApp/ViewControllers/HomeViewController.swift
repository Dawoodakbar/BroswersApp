//
//  HomeViewController.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Home View Controller
// Main screen that displays movies in different sections with genre filtering
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var movies: [Movie] = []
    private var genres: [Genre] = Genre.popularGenres
    private var selectedGenreId: Int = 0 // 0 means "All"
    private var isLoading = false
    private var searchWorkItem: DispatchWorkItem?
    
    // Movie sections for compositional layout
    private enum Section: Int, CaseIterable {
        case genres = 0
        case movies = 1
        
        var title: String {
            switch self {
            case .genres: return "Genres"
            case .movies: return "Movies"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🏠 HomeViewController: viewDidLoad")
        setupUI()
        setupCollectionView()
        setupConstraints()
        fetchInitialData()
        setupSearchController()
        // Load from Core Data first
        movies = CoreDataManager.shared.fetchMovies()
        
        if movies.isEmpty {
            fetchMoviesForSelectedGenre() // first 20 movies
        } else {
            collectionView.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh movies when returning from detail view (in case favorites changed)
        collectionView?.reloadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movies"
        
        // Add navigation bar styling
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Fetch from API & Save
    func fetchMoviesFromAPI(page: Int) {
        TMDBService.shared.fetchMovies(page: page) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedMovies):
                    self?.movies.append(contentsOf: fetchedMovies)
                    CoreDataManager.shared.saveMovies(fetchedMovies)
                    CoreDataManager.shared.printAllMovies()
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("❌ API fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        // Create compositional layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        collectionView.register(
            UINib(nibName: "GenreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GenreCollectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "MovieCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MovieCollectionViewCell"
        )
        
        // Register section headers
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        view.addSubview(collectionView)
        print("✅ HomeViewController: Collection view configured")
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("✅ HomeViewController: Constraints configured")
    }
    
    // MARK: - Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .genres:
                return self.createGenresSection()
            case .movies:
                return self.createMoviesSection()
            }
        }
    }
    
    // Horizontal scrolling genres section
    private func createGenresSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(40)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(40)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
        
        return section
    }
    
    // Vertical scrolling movies section
    private func createMoviesSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(280)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 16, trailing: 8)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(280)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return section
    }
    
    // MARK: - Data Fetching
    private func fetchInitialData() {
        fetchMoviesForSelectedGenre()
    }
    
    // Fetches movies based on selected genre
    private func fetchMoviesForSelectedGenre() {
        guard !isLoading else { return }
        
        isLoading = true
        print("🔄 HomeViewController: Fetching movies for genre ID: \(selectedGenreId)")
        
        // Show loading state
        // You can add a loading indicator here
        
        if selectedGenreId == 0 {
            // Fetch popular movies when "All" is selected
            TMDBService.shared.fetchPopularMovies { [weak self] result in
                self?.handleMovieResponse(result)
            }
        } else {
            // Fetch movies by specific genre
            TMDBService.shared.discoverMovies(genreId: selectedGenreId) { [weak self] result in
                self?.handleMovieResponse(result)
            }
        }
    }
    
    // Handles API response for movies
    private func handleMovieResponse(_ result: Result<[Movie], Error>) {
        isLoading = false
        
        switch result {
        case .success(let fetchedMovies):
            print("✅ HomeViewController: Received \(fetchedMovies.count) movies")
            self.movies = fetchedMovies
            
            DispatchQueue.main.async {
                // Reload only the movies section
                self.collectionView.reloadSections(IndexSet(integer: Section.movies.rawValue))
            }
            
        case .failure(let error):
            print("❌ HomeViewController: Failed to fetch movies - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // Shows error alert to user
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load movies: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.fetchMoviesForSelectedGenre()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    // Navigates to movie detail view - called when movie cell is tapped
    private func navigateToMovieDetail(movie: Movie) {
        print("🔄 HomeViewController: Navigating to detail for movie: \(movie.title)")
        let detailVC = MovieDetailViewController()
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Collection View Data Source
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .genres:
            return genres.count
        case .movies:
            return movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .genres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCollectionViewCell", for: indexPath) as! GenreCollectionViewCell
            let genre = genres[indexPath.item]
            cell.configure(with: genre, isSelected: genre.id == selectedGenreId)
            return cell
            
        case .movies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
            let movie = movies[indexPath.item]
            cell.configure(with: movie)
            return cell
        }
    }
}

// MARK: - Collection View Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .genres:
            // Handle genre selection
            let selectedGenre = genres[indexPath.item]
            if selectedGenreId != selectedGenre.id {
                selectedGenreId = selectedGenre.id
                print("🎯 HomeViewController: Selected genre: \(selectedGenre.name)")
                
                // Reload genres to update selection state
                collectionView.reloadSections(IndexSet(integer: Section.genres.rawValue))
                
                // Fetch movies for new genre
                fetchMoviesForSelectedGenre()
            }
            
        case .movies:
            // Handle movie selection - navigate to detail view
            let selectedMovie = movies[indexPath.item]
            navigateToMovieDetail(movie: selectedMovie)
        }
    }
}

// MARK: - Search bar
extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for movies..."
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // Called when user types
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        searchMovies(query: query) // reuse logic from SearchViewController
    }
    
    // Called when cancel button tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       // reset to all movies or empty
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension HomeViewController {
    
    // MARK: - Search Movies
    private func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            collectionView.reloadData()
            showEmptyState(message: "Search for your favorite movies")
            return
        }
        
        // Cancel previous search request
        searchWorkItem?.cancel()
        
        // Create new search work item with delay for better UX
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 1️⃣ First search in Core Data
            let localResults = CoreDataManager.shared.searchMovies(query: query)
            
            if !localResults.isEmpty {
                print("✅ Found results in Core Data")
                self.movies = localResults
                self.collectionView.reloadData()
                return
            }
            
            // 2️⃣ If not found in Core Data, search from API
            self.performSearch(query: query)
        }
        
        searchWorkItem = workItem
        
        // Execute search after 0.5 second delay to avoid too many API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    
    // MARK: - Search Methods
    
    private func performSearch(query: String) {
        print("🔎 Searching from API: \(query)")
        
        TMDBService.shared.searchMovies(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let fetchedMovies):
                    print("✅ API returned \(fetchedMovies.count) movies")
                    
                    // 1️⃣ Save them into Core Data (no duplicates handled inside CoreDataManager)
                    CoreDataManager.shared.saveMovies(fetchedMovies)
                    
                    // 2️⃣ Update UI
                    self.movies = fetchedMovies
                    self.collectionView.reloadData()
                    
                    if fetchedMovies.isEmpty {
                        self.showEmptyState(message: "No movies found")
                    }
                    
                case .failure(let error):
                    print("❌ API search failed: \(error.localizedDescription)")
                    self.showEmptyState(message: "Failed to fetch movies")
                }
            }
        }
    }

    
    private func handleSearchResponse(_ result: Result<[Movie], Error>, query: String) {
        isLoading = false
        hideLoadingState()
        
        switch result {
        case .success(let movies):
            print("✅ SearchViewController: Found \(movies.count) movies for '\(query)'")
            self.movies = movies
            collectionView.reloadData()
            
            if movies.isEmpty {
                showEmptyState(message: "No movies found for '\(query)'")
            }
            
        case .failure(let error):
            print("❌ SearchViewController: Search failed - \(error.localizedDescription)")
            showErrorState(message: error.localizedDescription)
        }
    }
    
    // MARK: - Loading States
    private func showLoadingState() {
        // You can implement a loading indicator here
        // For now, we'll just clear the collection view
        movies = []
        collectionView.reloadData()
    }
    
    private func hideLoadingState() {
        // Hide loading indicator when implemented
    }
    
    private func showEmptyState(message: String) {
        // You can implement a custom empty state view here
        print("📝 SearchViewController: Showing empty state - \(message)")
    }
    
    private func showErrorState(message: String) {
        let alert = UIAlertController(
            title: "Search Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
   
    }
    

    


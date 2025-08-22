//
//  FavoritesViewController.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Favorites View Controller
// Displays user's favorite movies from Core Data with management options
class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var favoriteMovies: [Movie] = []
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("❤️ FavoritesViewController: viewDidLoad")
        setupUI()
        setupCollectionView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Always refresh favorites when view appears (user might have added/removed favorites)
        loadFavorites()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add clear all button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllFavorites)
        )
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width - 48) / 2, height: 280)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register movie cell
        collectionView.register(
            UINib(nibName: "MovieCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MovieCollectionViewCell"
        )
        
        view.addSubview(collectionView)
        print("✅ FavoritesViewController: Collection view configured")
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("✅ FavoritesViewController: Constraints configured")
    }
    
    // MARK: - Data Loading
    private func loadFavorites() {
        print("🔄 FavoritesViewController: Loading favorites from Core Data")
        favoriteMovies = coreDataManager.fetchFavorites()
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.updateUI()
        }
        
        print("✅ FavoritesViewController: Loaded \(favoriteMovies.count) favorites")
    }
    
    private func updateUI() {
        // Update navigation bar button state
        navigationItem.rightBarButtonItem?.isEnabled = !favoriteMovies.isEmpty
        
        // Show empty state if no favorites
        if favoriteMovies.isEmpty {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        // You can implement a custom empty state view here
        print("📝 FavoritesViewController: No favorites found")
        
        // For now, just show an alert when first time opening with no favorites
        // In a real app, you'd show a nice empty state view
    }
    
    // MARK: - Actions
    @objc private func clearAllFavorites() {
        let alert = UIAlertController(
            title: "Clear All Favorites",
            message: "Are you sure you want to remove all favorite movies? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.performClearAll()
        })
        
        present(alert, animated: true)
    }
    
    private func performClearAll() {
        print("🗑️ FavoritesViewController: Clearing all favorites")
        
        // Remove all favorites from Core Data
        for movie in favoriteMovies {
            coreDataManager.removeFromFavorites(movieId: movie.id)
        }
        
        // Reload the view
        loadFavorites()
        
        print("✅ FavoritesViewController: All favorites cleared")
    }
    
    // MARK: - Navigation
    private func navigateToMovieDetail(movie: Movie) {
        print("🔄 FavoritesViewController: Navigating to detail for movie: \(movie.title)")
        let detailVC = MovieDetailViewController()
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Collection View Data Source
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = favoriteMovies[indexPath.item]
        cell.configure(with: movie)
        
        // Add favorite indicator to show these are saved
        cell.showFavoriteIndicator(true)
        
        return cell
    }
}

// MARK: - Collection View Delegate
extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = favoriteMovies[indexPath.item]
        navigateToMovieDetail(movie: selectedMovie)
    }
    
    // MARK: - Context Menu for Long Press
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = favoriteMovies[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let removeAction = UIAction(
                title: "Remove from Favorites",
                image: UIImage(systemName: "heart.slash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.removeFromFavorites(at: indexPath)
            }
            
            return UIMenu(title: movie.title, children: [removeAction])
        }
    }
    
    private func removeFromFavorites(at indexPath: IndexPath) {
        let movie = favoriteMovies[indexPath.item]
        
        print("🗑️ FavoritesViewController: Removing \(movie.title) from favorites")
        
        // Remove from Core Data
        coreDataManager.removeFromFavorites(movieId: movie.id)
        
        // Remove from local array
        favoriteMovies.remove(at: indexPath.item)
        
        // Update UI
        collectionView.deleteItems(at: [indexPath])
        updateUI()
        
        print("✅ FavoritesViewController: Successfully removed from favorites")
    }
}

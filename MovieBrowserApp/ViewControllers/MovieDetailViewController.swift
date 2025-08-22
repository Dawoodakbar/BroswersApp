//
//  MovieDetailViewController.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Movie Detail View Controller
// Displays detailed information about a selected movie with favorites functionality
class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    var movie: Movie! // Set by presenting view controller
    
    // UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var backdropImageView: UIImageView!
    private var posterImageView: UIImageView!
    private var titleLabel: UILabel!
    private var ratingLabel: UILabel!
    private var releaseDateLabel: UILabel!
    private var overviewLabel: UILabel!
    private var favoriteButton: UIButton!
    
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📱 MovieDetailViewController: viewDidLoad for movie: \(movie.title)")
        setupUI()
        setupScrollView()
        setupConstraints()
        configureContent()
        updateFavoriteButton()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = movie.title
        
        // Configure navigation bar
        navigationController?.navigationBar.tintColor = .systemBlue
        
        // Add share button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareMovie)
        )
    }
    
    // MARK: - Scroll View Setup
    private func setupScrollView() {
        // Scroll View
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Content View
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Backdrop Image View
        backdropImageView = UIImageView()
        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true
        backdropImageView.backgroundColor = .systemGray5
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backdropImageView)
        
        // Poster Image View
        posterImageView = UIImageView()
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .systemGray5
        posterImageView.layer.cornerRadius = 8
        posterImageView.layer.borderWidth = 3
        posterImageView.layer.borderColor = UIColor.systemBackground.cgColor
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Rating Label
        ratingLabel = UILabel()
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ratingLabel.textColor = .systemOrange
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingLabel)
        
        // Release Date Label
        releaseDateLabel = UILabel()
        releaseDateLabel.font = UIFont.systemFont(ofSize: 14)
        releaseDateLabel.textColor = .secondaryLabel
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(releaseDateLabel)
        
        // Overview Label
        overviewLabel = UILabel()
        overviewLabel.font = UIFont.systemFont(ofSize: 16)
        overviewLabel.numberOfLines = 0
        overviewLabel.textColor = .label
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(overviewLabel)
        
        // Favorite Button
        favoriteButton = UIButton(type: .system)
        favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        favoriteButton.layer.cornerRadius = 25
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        print("✅ MovieDetailViewController: UI elements created")
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Backdrop Image View
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Poster Image View
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -50),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 20),
            
            // Rating Label
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // Release Date Label
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            
            // Favorite Button
            favoriteButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            favoriteButton.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Overview Label
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        print("✅ MovieDetailViewController: Constraints configured")
    }
    
    // MARK: - Content Configuration
    private func configureContent() {
        // Set text content
        titleLabel.text = movie.title
        ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))/10"
        releaseDateLabel.text = "Released: \(movie.formattedReleaseDate)"
        overviewLabel.text = movie.overview.isEmpty ? "No overview available." : movie.overview
        
        // Load images asynchronously
        loadImages()
        
        print("✅ MovieDetailViewController: Content configured")
    }
    
    private func loadImages() {
        // Load backdrop image
        if let backdropURL = movie.fullBackdropURL {
            backdropImageView.loadImage(from: backdropURL)
        }
        
        // Load poster image
        if let posterURL = movie.fullPosterURL {
            posterImageView.loadImage(from: posterURL)
        }
    }
    
    private func updateFavoriteButton() {
        let isFavorite = coreDataManager.isFavorite(movieId: movie.id)
        
        if isFavorite {
            favoriteButton.setTitle("💖 Remove from Favorites", for: .normal)
            favoriteButton.backgroundColor = .systemRed.withAlphaComponent(0.1)
            favoriteButton.setTitleColor(.systemRed, for: .normal)
            favoriteButton.layer.borderWidth = 1
            favoriteButton.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            favoriteButton.setTitle("❤️ Add to Favorites", for: .normal)
            favoriteButton.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            favoriteButton.setTitleColor(.systemBlue, for: .normal)
            favoriteButton.layer.borderWidth = 1
            favoriteButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
        
        print("🔄 MovieDetailViewController: Updated favorite button - isFavorite: \(isFavorite)")
    }
    
    // MARK: - Actions
    @objc private func favoriteButtonTapped() {
        let isFavorite = coreDataManager.isFavorite(movieId: movie.id)
        
        if isFavorite {
            // Remove from favorites
            coreDataManager.removeFromFavorites(movieId: movie.id)
            print("💔 MovieDetailViewController: Removed \(movie.title) from favorites")
            showToast(message: "Removed from favorites")
        } else {
            // Add to favorites
            coreDataManager.addToFavorites(movie: movie)
            print("💖 MovieDetailViewController: Added \(movie.title) to favorites")
            showToast(message: "Added to favorites")
        }
        
        // Update button appearance
        updateFavoriteButton()
    }
    
    @objc private func shareMovie() {
        let shareText = "\(movie.title) - \(movie.formattedReleaseDate)\n\n\(movie.overview)"
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true)
        print("📤 MovieDetailViewController: Sharing movie: \(movie.title)")
    }
    
    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // Auto dismiss after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
}

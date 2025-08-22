//
//  MovieCollectionViewCell.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Movie Collection View Cell
// Custom cell for displaying movie information in collection views
class MovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets (connected from nib file)
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favoriteIndicator: UIImageView!
    
    // MARK: - Properties
    static let identifier = "MovieCollectionViewCell"
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        print("🎬 MovieCollectionViewCell: awakeFromNib")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset cell content to avoid reuse issues
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
        favoriteIndicator.isHidden = true
        
        // Reset any animations or states
        transform = .identity
        alpha = 1.0
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Cell appearance
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        // Poster Image View
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.backgroundColor = .systemGray5
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        // Rating Label
        ratingLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        ratingLabel.textColor = .systemOrange
        ratingLabel.textAlignment = .center
        
        // Favorite Indicator
        favoriteIndicator.image = UIImage(systemName: "heart.fill")
        favoriteIndicator.tintColor = .systemRed
        favoriteIndicator.isHidden = true
        
        print("✅ MovieCollectionViewCell: UI configured")
    }
    
    // MARK: - Configuration
    // Called by view controllers to populate cell with movie data
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))"
        
        // Load poster image
        if let posterURL = movie.fullPosterURL {
            posterImageView.loadImage(from: posterURL)
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
        
        // Check if movie is in favorites and show indicator
        let isFavorite = CoreDataManager.shared.isFavorite(movieId: movie.id)
        showFavoriteIndicator(isFavorite)
        
        print("🎬 MovieCollectionViewCell: Configured with movie: \(movie.title)")
    }
    
    // Shows or hides favorite indicator
    func showFavoriteIndicator(_ show: Bool) {
        favoriteIndicator.isHidden = !show
    }
    
    // MARK: - Animation Methods
    // Called when cell is selected to provide visual feedback
    func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}

// MARK: - Nib Loading
extension MovieCollectionViewCell {
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

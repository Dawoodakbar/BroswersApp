//
//  GenreCollectionViewCell.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//
import UIKit

// MARK: - Genre Collection View Cell
// Custom cell for displaying genre selection buttons
class GenreCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets (connected from nib file)
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    static let identifier = "GenreCollectionViewCell"
    private var isSelectedState = false
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        print("🏷️ GenreCollectionViewCell: awakeFromNib")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset selection state
        updateSelectionState(false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Container View (acts as button background)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        
        // Genre Label
        genreLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        genreLabel.textAlignment = .center
        
        // Initial unselected state
        updateSelectionState(false)
        
        print("✅ GenreCollectionViewCell: UI configured")
    }
    
    // MARK: - Configuration
    // Called by HomeViewController to populate cell with genre data
    func configure(with genre: Genre, isSelected: Bool) {
        genreLabel.text = genre.name
        updateSelectionState(isSelected)
        
        print("🏷️ GenreCollectionViewCell: Configured with genre: \(genre.name), selected: \(isSelected)")
    }
    
    // MARK: - Selection State
    private func updateSelectionState(_ selected: Bool) {
        isSelectedState = selected
        
        UIView.animate(withDuration: 0.2) {
            if selected {
                // Selected state - filled background
                self.containerView.backgroundColor = .systemBlue
                self.containerView.layer.borderColor = UIColor.systemBlue.cgColor
                self.genreLabel.textColor = .white
                
                // Slight scale up for selected state
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                // Unselected state - clear background with border
                self.containerView.backgroundColor = .clear
                self.containerView.layer.borderColor = UIColor.systemGray3.cgColor
                self.genreLabel.textColor = .label
                
                // Normal scale
                self.transform = .identity
            }
        }
    }
    
    // MARK: - Animation Methods
    // Called when cell is tapped to provide visual feedback
    func animateTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                if self.isSelectedState {
                    self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } else {
                    self.transform = .identity
                }
            }
        }
    }
}

// MARK: - Nib Loading
extension GenreCollectionViewCell {
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

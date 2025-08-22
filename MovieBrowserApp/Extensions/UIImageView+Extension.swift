//
//  UIImageView+Extension.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - UIImageView Extensions
// Adds async image loading capabilities to UIImageView
extension UIImageView {
    
    // MARK: - Image Loading
    // Loads image from URL with caching and placeholder handling
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        // Set placeholder immediately
        if let placeholder = placeholder {
            self.image = placeholder
        } else {
            // Use system placeholder
            self.image = UIImage(systemName: "photo.fill")
            self.tintColor = .systemGray3
        }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: url) {
            DispatchQueue.main.async {
                self.image = cachedImage
                self.tintColor = nil
            }
            return
        }
        
        // Download image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                print("❌ Failed to load image from: \(url)")
                return
            }
            
            // Cache the image
            ImageCache.shared.setImage(image, for: url)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self?.image = image
                self?.tintColor = nil
                
                // Add fade-in animation
                self?.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self?.alpha = 1
                }
            }
        }.resume()
    }
}

// MARK: - Image Cache
// Simple image caching system to improve performance
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // Maximum 50MB
        
        print("🗄️ ImageCache: Initialized with limits")
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        print("🗑️ ImageCache: Cache cleared")
    }
}

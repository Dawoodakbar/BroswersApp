//
//  TabBarController.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Tab Bar Controller
// Main navigation controller that manages all app tabs
class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        configureViewControllers()
        customizeAppearance()
        
    }
    
    // MARK: - Tab Bar Setup
    private func setupTabBar() {
        // Configure tab bar appearance
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // Add subtle shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 3
        tabBar.layer.shadowOpacity = 0.1
    }
    
    // MARK: - View Controllers Configuration
    private func configureViewControllers() {
        // 1. Home Tab - Shows all movies with genre filtering
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 3. Favorites Tab - Core Data saved movies
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        // 4. Profile Tab - User profile
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // Assign all view controllers to tab bar
        viewControllers = [homeNav, favoritesNav, profileNav]
        
        print("✅ TabBar: Configured with \(viewControllers?.count ?? 0) tabs")
    }
    
    // MARK: - Appearance Customization
    private func customizeAppearance() {
        // Configure navigation bars for all tabs
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Bar Controller Extensions
extension TabBarController {
    // Method to programmatically switch tabs - can be called from other view controllers
    func switchToTab(_ index: Int) {
        selectedIndex = index
    }
    
    // Method to show badge on specific tabs (e.g., favorites count)
    func setBadge(_ badgeValue: String?, for tabIndex: Int) {
        guard let tabItems = tabBar.items, tabIndex < tabItems.count else { return }
        tabItems[tabIndex].badgeValue = badgeValue
    }
}






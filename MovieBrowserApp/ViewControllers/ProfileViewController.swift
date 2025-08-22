//
//  ProfileViewController.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

// MARK: - Profile View Controller
// Displays user profile information and app settings
class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    
    // Profile sections
    private enum Section: Int, CaseIterable {
        case user = 0
        case statistics = 1
        case settings = 2
        case about = 3
        
        var title: String {
            switch self {
            case .user: return "Profile"
            case .statistics: return "Statistics"
            case .settings: return "Settings"
            case .about: return "About"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("👤 ProfileViewController: viewDidLoad")
        setupUI()
        setupTableView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh statistics when view appears
        tableView.reloadSections(IndexSet(integer: Section.statistics.rawValue), with: .none)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Table View Setup
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        
        view.addSubview(tableView)
        print("✅ ProfileViewController: Table view configured")
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("✅ ProfileViewController: Constraints configured")
    }
    
    // MARK: - Helper Methods
    private func getFavoritesCount() -> Int {
        return CoreDataManager.shared.fetchFavorites().count
    }
    
    // MARK: - Actions
    private func handleSettingsTap(setting: String) {
        print("⚙️ ProfileViewController: Settings tapped - \(setting)")
        
        switch setting {
        case "Notifications":
            showNotificationSettings()
        case "Clear Cache":
            showClearCacheAlert()
        case "Privacy Policy":
            showPrivacyPolicy()
        case "Terms of Service":
            showTermsOfService()
        default:
            break
        }
    }
    
    private func showNotificationSettings() {
        let alert = UIAlertController(
            title: "Notifications",
            message: "Notification settings would be configured here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showClearCacheAlert() {
        let alert = UIAlertController(
            title: "Clear Cache",
            message: "Are you sure you want to clear the app cache?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            // Implement cache clearing logic here
            print("🗑️ ProfileViewController: Cache cleared")
        })
        present(alert, animated: true)
    }
    
    private func showPrivacyPolicy() {
        let alert = UIAlertController(
            title: "Privacy Policy",
            message: "Privacy policy would be displayed here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showTermsOfService() {
        let alert = UIAlertController(
            title: "Terms of Service",
            message: "Terms of service would be displayed here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .user: return 2
        case .statistics: return 2
        case .settings: return 4
        case .about: return 3
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        return section.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = "Movie Lover"
                cell.imageView?.image = UIImage(systemName: "person.circle")
            } else {
                cell.textLabel?.text = "Email"
                cell.detailTextLabel?.text = "user@example.com"
                cell.imageView?.image = UIImage(systemName: "envelope")
            }
            cell.selectionStyle = .none
            return cell
            
        case .statistics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Favorite Movies"
                cell.detailTextLabel?.text = "\(getFavoritesCount())"
                cell.imageView?.image = UIImage(systemName: "heart.fill")
            } else {
                cell.textLabel?.text = "Movies Watched"
                cell.detailTextLabel?.text = "Coming Soon"
                cell.imageView?.image = UIImage(systemName: "play.circle")
            }
            cell.selectionStyle = .none
            return cell
            
        case .settings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            let settings = ["Notifications", "Clear Cache", "Privacy Policy", "Terms of Service"]
            let icons = ["bell", "trash", "lock.shield", "doc.text"]
            
            cell.textLabel?.text = settings[indexPath.row]
            cell.imageView?.image = UIImage(systemName: icons[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            let aboutItems = [
                ("Version", "1.0.0"),
                ("Developer", "Movie Browser Team"),
                ("Contact", "support@moviebrowser.com")
            ]
            let icons = ["info.circle", "person.2", "envelope.circle"]
            
            let item = aboutItems[indexPath.row]
            cell.textLabel?.text = item.0
            cell.detailTextLabel?.text = item.1
            cell.imageView?.image = UIImage(systemName: icons[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - Table View Delegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        if section == .settings {
            let settings = ["Notifications", "Clear Cache", "Privacy Policy", "Terms of Service"]
            handleSettingsTap(setting: settings[indexPath.row])
        }
    }
}


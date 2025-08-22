//
//  SceneDelegate.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
                  willConnectTo session: UISceneSession,
                  options connectionOptions: UIScene.ConnectionOptions) {
           guard let windowScene = (scene as? UIWindowScene) else { return }

           window = UIWindow(windowScene: windowScene)

           // Tab 1: Home
           let homeVC = UINavigationController(rootViewController: HomeViewController())
           homeVC.tabBarItem = UITabBarItem(title: "Home",
                                            image: UIImage(systemName: "house"),
                                            tag: 0)

           // Tab 3: Favorites
           let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
           favoritesVC.tabBarItem = UITabBarItem(title: "Favorites",
                                                 image: UIImage(systemName: "star"),
                                                 tag: 2)

           // Tab 4: Profile
           let profileVC = UINavigationController(rootViewController: ProfileViewController())
           profileVC.tabBarItem = UITabBarItem(title: "Profile",
                                               image: UIImage(systemName: "person"),
                                               tag: 3)

           // Create Tab Bar Controller
           let tabBarController = UITabBarController()
           tabBarController.viewControllers = [homeVC, favoritesVC, profileVC]

           // Set Root View Controller
           window?.rootViewController = tabBarController
           window?.makeKeyAndVisible()
       }
   }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }





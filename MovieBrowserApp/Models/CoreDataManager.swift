//
//  CoreDataManager.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import Foundation
import CoreData

// MARK: - Core Data Manager
// Singleton class that handles all Core Data operations for favorite movies
class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieBrowserApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Operations
    // Fetch Movies
    func fetchMovies() -> [Movie] {
            let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            do {
                let results = try context.fetch(request)
                return results.map { Movie(id: Int($0.id),
                                           title: $0.title ?? "",
                                           overview: $0.overview ?? "",
                                           posterPath: $0.posterPath,
                                           backdropPath: $0.backdropPath,
                                           releaseDate: $0.releaseDate ?? "",
                                           voteAverage: $0.voteAverage,
                                           genreIds: $0.genreIds ,
                                           popularity: $0.popularity) }
            } catch {
                print("❌ Failed to fetch movies: \(error)")
                return []
            }
        }
    func printAllMovies() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let movies = try context.fetch(fetchRequest)
            print("📀 Core Data has \(movies.count) movies")
            for movie in movies {
                print("🎬 \(movie.title ?? "No Title") (ID: \(movie.id))")
            }
        } catch {
            print("❌ Failed to fetch movies: \(error.localizedDescription)")
        }
    }

    
    // Search movies locally
        func searchMovies(query: String) -> [Movie] {
            let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            
            do {
                let results = try context.fetch(request)
                return results.map { Movie(id: Int($0.id),
                                           title: $0.title ?? "",
                                           overview: $0.overview ?? "",
                                           posterPath: $0.posterPath,
                                           backdropPath: $0.backdropPath,
                                           releaseDate: $0.releaseDate ?? "",
                                           voteAverage: $0.voteAverage,
                                           genreIds: $0.genreIds,
                                           popularity: $0.popularity) }
            } catch {
                print("❌ Failed to search movies: \(error)")
                return []
            }
        }
    
    // Saving movies to the core data
    func saveMovies(_ movies: [Movie]) {
        
           for movie in movies {
               let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
               request.predicate = NSPredicate(format: "id == %d", movie.id)
               
               if let existing = try? context.fetch(request).first {
                   // Update if already exists
                   existing.title = movie.title
                   existing.overview = movie.overview
                   existing.posterPath = movie.posterPath
                   existing.releaseDate = movie.releaseDate
               } else {
                   // Insert new
                   let entity = MovieEntity(context: context)
                   entity.id = Int32(movie.id)
                   entity.title = movie.title
                   entity.overview = movie.overview
                   entity.posterPath = movie.posterPath
                   entity.releaseDate = movie.releaseDate
                   entity.voteAverage = movie.voteAverage
                   entity.popularity = movie.popularity
               }
           }
           
           do {
               try context.save()
               print("✅ Movies saved to Core Data")
           } catch {
               print("❌ Failed to save movies: \(error)")
           }
       }
    
    
    // Saves the current context to persistent store
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data: Successfully saved context")
            } catch {
                print("❌ Core Data Save Error: \(error)")
            }
        }
    }
    
    // MARK: - Favorites Management
    
    // Adds a movie to favorites
    // Called from: MovieDetailViewController when user taps favorite button
    func addToFavorites(movie: Movie) {
        // Check if already exists to avoid duplicates
        if !isFavorite(movieId: movie.id) {
            let favoriteMovie = NSEntityDescription.entity(forEntityName: "FavoriteMovie", in: context)!
            let newFavorite = NSManagedObject(entity: favoriteMovie, insertInto: context)
            
            newFavorite.setValue(movie.id, forKey: "id")
            newFavorite.setValue(movie.title, forKey: "title")
            newFavorite.setValue(movie.overview, forKey: "overview")
            newFavorite.setValue(movie.posterPath, forKey: "posterPath")
            newFavorite.setValue(movie.releaseDate, forKey: "releaseDate")
            newFavorite.setValue(movie.voteAverage, forKey: "voteAverage")
            newFavorite.setValue(Date(), forKey: "dateAdded")
            
            saveContext()
            print("✅ Added to favorites: \(movie.title)")
        }
    }
    
    // Removes a movie from favorites
    // Called from: MovieDetailViewController or FavoritesViewController
    func removeFromFavorites(movieId: Int) {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoriteMovie")
        request.predicate = NSPredicate(format: "id == %d", movieId)
        
        do {
            let results = try context.fetch(request)
            if let movieToDelete = results.first {
                context.delete(movieToDelete)
                saveContext()
                print("✅ Removed from favorites: Movie ID \(movieId)")
            }
        } catch {
            print("❌ Error removing from favorites: \(error)")
        }
    }
    
    // Checks if a movie is already in favorites
    // Called from: MovieDetailViewController to update UI state
    func isFavorite(movieId: Int) -> Bool {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoriteMovie")
        request.predicate = NSPredicate(format: "id == %d", movieId)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Error checking favorite status: \(error)")
            return false
        }
    }
    
    // Fetches all favorite movies
    // Called from: FavoritesViewController to display favorites list
    func fetchFavorites() -> [Movie] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoriteMovie")
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { managedObject in
                // Convert Core Data object back to Movie model
                guard let id = managedObject.value(forKey: "id") as? Int,
                      let title = managedObject.value(forKey: "title") as? String,
                      let overview = managedObject.value(forKey: "overview") as? String,
                      let releaseDate = managedObject.value(forKey: "releaseDate") as? String,
                      let voteAverage = managedObject.value(forKey: "voteAverage") as? Double else {
                    return nil
                }
                
                let posterPath = managedObject.value(forKey: "posterPath") as? String
                
                return Movie(id: id,
                           title: title,
                           overview: overview,
                           posterPath: posterPath,
                           backdropPath: nil,
                           releaseDate: releaseDate,
                           voteAverage: voteAverage,
                           genreIds: [],
                           popularity: 0)
            }
        } catch {
            print("❌ Error fetching favorites: \(error)")
            return []
        }
    }
}

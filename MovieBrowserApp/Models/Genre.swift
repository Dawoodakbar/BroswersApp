//
//  Genre.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//


import Foundation

// MARK: - Genre Model
// Represents a movie genre from TMDB API
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - Genre Response
// Wrapper for TMDB API genre response
struct GenreResponse: Codable {
    let genres: [Genre]
}

// MARK: - Genre Extensions
extension Genre {
    // Predefined popular genres for quick access
    static let popularGenres: [Genre] = [
        Genre(id: 0, name: "All"), // Special case for showing all movies
        Genre(id: 28, name: "Action"),
        Genre(id: 12, name: "Adventure"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 35, name: "Comedy"),
        Genre(id: 80, name: "Crime"),
        Genre(id: 18, name: "Drama"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 27, name: "Horror"),
        Genre(id: 10749, name: "Romance"),
        Genre(id: 878, name: "Sci-Fi"),
        Genre(id: 53, name: "Thriller")
    ]
}

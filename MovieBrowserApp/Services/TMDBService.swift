//
//  TMDBService.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//

import Foundation

// MARK: - TMDB Service
// Singleton service class that handles all TMDB API communications
class TMDBService {
    static let shared = TMDBService()
    
    private init() {}
    
    // MARK: - API Configuration
    private let apiKey = "5626b8a525a69293311a0633e7738d97" // Replace with your actual API key
    private let baseURL = "https://api.themoviedb.org/3"
    
    // MARK: - API Endpoints
    enum Endpoint {
        case popular
        case topRated
        case upcoming
        case nowPlaying
        case search(query: String)
        case discover(genreId: Int)
        case genres
        
        var path: String {
            switch self {
            case .popular: return "/movie/popular"
            case .topRated: return "/movie/top_rated"
            case .upcoming: return "/movie/upcoming"
            case .nowPlaying: return "/movie/now_playing"
            case .search: return "/search/movie"
            case .discover: return "/discover/movie"
            case .genres: return "/genre/movie/list"
            }
        }
        
        var queryItems: [URLQueryItem] {
            var items = [URLQueryItem(name: "api_key", value: TMDBService.shared.apiKey)]
            
            switch self {
            case .search(let query):
                items.append(URLQueryItem(name: "query", value: query))
            case .discover(let genreId):
                if genreId != 0 { // 0 means "All" genres
                    items.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
                }
                items.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            default:
                break
            }
            
            return items
        }
    }
    
    // MARK: - API Methods
    // Fetche Movies
    func fetchMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
            let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=en-US&page=\(page)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "InvalidURL", code: 0)))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: 0)))
                    return
                }
                
                do {
                    // decode into TMDB API response format
                    let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                    completion(.success(response.results))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    // Fetches popular movies - Called by HomeViewController
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        performRequest(endpoint: .popular, completion: completion)
    }
    
    // Fetches top-rated movies - Called by HomeViewController
    func fetchTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        performRequest(endpoint: .topRated, completion: completion)
    }
    
    // Fetches upcoming movies - Called by HomeViewController
    func fetchUpcomingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        performRequest(endpoint: .upcoming, completion: completion)
    }
    
    // Fetches now playing movies - Called by HomeViewController
    func fetchNowPlayingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        performRequest(endpoint: .nowPlaying, completion: completion)
    }
    
    // Searches for movies - Called by SearchViewController
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        performRequest(endpoint: .search(query: query), completion: completion)
    }
    
    
    // Discovers movies by genre - Called by HomeViewController when genre is selected
    func discoverMovies(genreId: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        performRequest(endpoint: .discover(genreId: genreId), completion: completion)
    }
    
    // Fetches available genres - Called by HomeViewController on initial load
    func fetchGenres(completion: @escaping (Result<[Genre], Error>) -> Void) {
        guard let url = buildURL(for: .genres) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(TMDBError.noData))
                    return
                }
                
                do {
                    let genreResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                    completion(.success(genreResponse.genres))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Private Helper Methods
    
    // Generic method to perform API requests and parse movie responses
    private func performRequest(endpoint: Endpoint, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = buildURL(for: endpoint) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        
        print("🌐 API Request: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ API Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(TMDBError.noData))
                    return
                }
                
                do {
                    let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                    print("✅ API Success: Fetched \(movieResponse.results.count) movies")
                    completion(.success(movieResponse.results))
                } catch {
                    print("❌ JSON Parsing Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // Builds complete URL for API endpoints
    private func buildURL(for endpoint: Endpoint) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return nil
        }
        components.queryItems = endpoint.queryItems
        return components.url
    }
}

// MARK: - Custom Errors
enum TMDBError: LocalizedError {
    case invalidURL
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        }
    }
}

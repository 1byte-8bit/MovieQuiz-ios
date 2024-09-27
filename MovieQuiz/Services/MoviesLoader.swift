//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Alexandr on 06.07.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        
        var apiKey: String {
            get {
                guard let filePath = Bundle.main.path(forResource: "api", ofType: "plist") else {
                    fatalError("Couldn't find file 'api.plist'.")
                }
                let plist = NSDictionary(contentsOfFile: filePath)
                guard let value = plist?.object(forKey: "API_KEY") as? String else {
                      fatalError("Couldn't find key 'API_KEY' in 'api.plist'.")
                    }
                
                return value
            }
        }
        
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/\(apiKey)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

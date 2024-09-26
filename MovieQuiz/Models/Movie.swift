//
//  Movie.swift
//  MovieQuiz
//
//  Created by Alexandr on 23.06.2023.
//

import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
    
    let id: String
    let rank: Int // Int
    let title: String
    let fullTitle: String
    let year: Int // Int
    let image: String
    let crew: String
    let imDbRating: Double // Double
    let imDbRatingCount: Int // Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        self.rank = Int(rankValue)
        
        title = try container.decode(String.self, forKey: .title)
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue
        
        image = try container.decode(String.self, forKey: .image)
        crew = try container.decode(String.self, forKey: .crew)
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let imDbRatingValue = Double(imDbRating) else {
            throw ParseError.imDbRating
        }
        self.imDbRating = imDbRatingValue
        
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let imDbRatingCountValue = Int(imDbRatingCount) else {
            throw ParseError.imDbRatingCount
        }
        self.imDbRatingCount = imDbRatingCountValue
    }
}

struct Top: Decodable {
    let items: [Movie]
    let errorMessage: String
}

enum CodingKeys: CodingKey {
    case id, rank, title, fullTitle, year, image, crew, imDbRating, imDbRatingCount
}

enum ParseError: Error {
    case rankFailure
    case yearFailure
    case imDbRating
    case imDbRatingCount
}

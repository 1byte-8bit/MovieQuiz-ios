//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Alexandr on 29.06.2023.
//

import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        if lhs.correct < rhs.correct {
            return true
        } else {
            return false
        }
    }
}

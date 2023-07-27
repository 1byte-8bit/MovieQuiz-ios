//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Alexandr on 26.06.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        
        if bestGame < currentGame {
            bestGame = currentGame
        }
        
        gamesCount += 1
        
        totalCorrect += count
        totalAmount += amount
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // Средняя точность
    var totalAccuracy: Double {
        get {
            // Проверка totalAmount на неравность 0 перед выполнением подсчета
            guard totalAmount != 0 else {
                return 0
            }
            return Double(totalCorrect) / Double(totalAmount) * 100
        }
    }
    
    // Количество игр
    var gamesCount: Int {
        get {
            let count = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return count
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var totalCorrect: Int {
        get {
            let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
            return correct
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
            
        }
    }
    
    private(set) var totalAmount: Int {
        get {
            let total = userDefaults.integer(forKey: Keys.total.rawValue)
            return total
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
}

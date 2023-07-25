//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation


class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма \n больше чем 6?",
//            correctAnswer: false),
//    ]
    
    private var movies: [MostPopularMovie] = []
    
    private func generateQuestion(with rating: Float) -> (text: String, correctAnswer: Bool) {
        // Experiment on creating various questions
        let arrayOfOperators = ["<", ">"]

        let sing = arrayOfOperators.randomElement()
        // Получения рандомного числа методом arc4random_uniform()
        // вместо Int.random(in: 6...9)
        var randomNumber = arc4random_uniform(9)
        while randomNumber < 6 {
            randomNumber = arc4random_uniform(9)
        }
        
        var text: String
        var correctAnswer: Bool
        // Создание варианта вопроса
        if sing == "<" {
            text = "Рейтинг этого фильма  меньше чем \(randomNumber)?"
            correctAnswer = rating < Float(randomNumber)
        } else {
            text = "Рейтинг этого фильма  больше чем \(randomNumber)?"
            correctAnswer = rating > Float(randomNumber)
        }
        
        return (text, correctAnswer)
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    print(mostPopularMovies)
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
   }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
               imageData = try Data(contentsOf: movie.resizedImageURL)
               print(imageData)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            
            let question = generateQuestion(with: rating)
            let text = question.text
            let correctAnswer = question.correctAnswer
            
            print(text)
            print(correctAnswer)
            
            let quizQuestion = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: quizQuestion)
            }
        }
    }

    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
}



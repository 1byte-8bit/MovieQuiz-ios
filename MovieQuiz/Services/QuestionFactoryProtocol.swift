//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}

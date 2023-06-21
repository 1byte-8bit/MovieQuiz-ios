//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

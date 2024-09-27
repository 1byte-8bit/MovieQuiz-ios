//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    // сообщение об успешной загрузке
    func didLoadDataFromServer()
    // сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error)
}

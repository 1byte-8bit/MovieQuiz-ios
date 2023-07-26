//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alexandr on 26.07.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return question
    }
    
    // MARK: - Actions
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = true
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = false
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
}


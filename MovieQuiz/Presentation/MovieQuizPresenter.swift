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
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    
    private var statisticService: StatisticService?
    
    var questionFactory: QuestionFactoryProtocol?
    
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
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
        
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        self.viewController?.hideLoadingIndicator()
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
        
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    /// приватный метод, который содержит логику перехода в один из сценариев
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идём в состояние "Результат квиза"
            statisticService = StatisticServiceImplementation()
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let accuracy = statisticService?.totalAccuracy ?? Double(correctAnswers) * 100 / 10
            let gamesCount = statisticService?.gamesCount ?? 1
            let gameRecord = statisticService?.bestGame
            let date = gameRecord?.date ?? Date()
            
            let message = "Ваш результат: \(correctAnswers)/\(questionsAmount) очков\n"
            + "Количество сыграных квизов: \(gamesCount)\n"
            + "Рекорд: \(gameRecord?.correct ?? correctAnswers)/"
            + "\(gameRecord?.total ?? questionsAmount) (\(date.dateTimeString))\n"
            + "Средняя точность: \(String(format: "%.2f", accuracy))%"
            
            let resultMessage = AlertModel(
                accessibilityId: "Game results",
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            viewController?.alertPresenter?.showGameResult(with: resultMessage)
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
        
        viewController?.noButton.isEnabled = true
        viewController?.yesButton.isEnabled = true
        
      }
    
    
}


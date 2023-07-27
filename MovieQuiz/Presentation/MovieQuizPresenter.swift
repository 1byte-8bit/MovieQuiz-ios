//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alexandr on 26.07.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов
    private var correctAnswers: Int = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
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
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
        
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        /// метод, который меняет цвет рамки
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // код, который мы хотим вызвать через 1 секунду
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
        }
    }
    
    /// метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showResult()
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
        
        viewController?.switchButton(state: true)
        
      }
    
    func makeResultsMessage() -> String {
        // идём в состояние "Результат квиза"
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
        
        return message
    }
    
}


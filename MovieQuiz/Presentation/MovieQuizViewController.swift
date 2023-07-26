import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    /*
     Question Factory передана Инъекцией через свойство
     а делегат организован в нем Агрегацией (метод связи)
     т.е. через параметр в инициализаторе
     */
    
    // Делает содержимое статус бара светлым
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        // настройка индикатора загрузки
        activityIndicator.style = .large
        activityIndicator.color = .ypWhite
        activityIndicator.hidesWhenStopped = true
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        // Показываем индикатор и загружаем изображение
        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(mainViewController: self)
        
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        hideLoadingIndicator()
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Private functions
    /// приватный метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = .nan // толщина рамки
        
    }
    
    /// приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        /// метод красит рамку
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // код, который мы хотим вызвать через 1 секунду
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    /// приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идём в состояние "Результат квиза"
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let accuracy = statisticService?.totalAccuracy ?? Double(correctAnswers) * 100 / 10
            let gamesCount = statisticService?.gamesCount ?? 1
            let gameRecord = statisticService?.bestGame
            let date = gameRecord?.date ?? Date()
            
            let message = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount) очков\n"
            + "Количество сыграных квизов: \(gamesCount)\n"
            + "Рекорд: \(gameRecord?.correct ?? correctAnswers)/"
            + "\(gameRecord?.total ?? presenter.questionsAmount) (\(date.dateTimeString))\n"
            + "Средняя точность: \(String(format: "%.2f", accuracy))%"
            
            let resultMessage = AlertModel(
                accessibilityId: "Game results",
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter?.showGameResult(with: resultMessage)
        } else {
            self.presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
        
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
      }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
}


extension MovieQuizViewController {
    
    func didLoadDataFromServer() {
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

extension MovieQuizViewController {
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}

extension MovieQuizViewController {
    
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let resultMessage = AlertModel(
            accessibilityId: "Network Error",
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.loadData()
            }
        )
        presentAlert(model: resultMessage)
    }
}

extension MovieQuizViewController {
    func presentAlert(model: AlertModel?) {
        self.present(self, animated: true)
    }
}

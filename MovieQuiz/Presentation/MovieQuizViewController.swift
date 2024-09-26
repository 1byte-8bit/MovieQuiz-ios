import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    /*
     Question Factory передана Инъекцией через свойство
     а делегат организован в нем Агрегацией (метод связи)
     т.е. через параметр в инициализаторе
     */
    
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // Делает содержимое статус бара светлым
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(mainViewController: self)
        
        statisticService = StatisticServiceImplementation()
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
    
    // MARK: - Private functions
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return question
    }
    
    // приватный метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = .nan // толщина рамки
        
    }
    
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
       // метод красит рамку
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
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
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
            
            let resultMessage = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter?.showGameResult(with: resultMessage)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
        
        self.noButton.isEnabled = true
        self.yesButton.isEnabled = true
        
      }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

}

extension MovieQuizViewController {
    func presentAlert(model: AlertModel?) {
        self.present(self, animated: true)
    }
}


extension MovieQuizViewController {
    
    func getMovie(from jsonString: String) -> Top? {
        
        var movie: Top? = nil
        
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let movieModel = try JSONDecoder().decode(Top.self, from: data)

            movie = movieModel
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
        }
        
        return movie
    }
}

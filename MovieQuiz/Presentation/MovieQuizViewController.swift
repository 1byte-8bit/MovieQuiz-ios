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
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    
    var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenterProtocol?
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        // настройка индикатора загрузки
        activityIndicator.style = .large
        activityIndicator.color = .ypWhite
        activityIndicator.hidesWhenStopped = true
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        // Показываем индикатор и загружаем изображение
        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(mainViewController: self)
        
        
    }
    
    // MARK: - Private functions
    /// приватный метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = .nan // толщина рамки
        
    }
    
    /// приватный метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
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
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
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
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
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

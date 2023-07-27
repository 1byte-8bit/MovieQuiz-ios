import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
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
    
    var alertPresenter: AlertPresenterProtocol?
    
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(mainViewController: self)
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        // настройка индикатора загрузки
        activityIndicator.style = .large
        activityIndicator.color = .ypWhite
        activityIndicator.hidesWhenStopped = true
    }
    
    /// метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = .nan // толщина рамки
        
    }
    
    func showResult() {
        let message = presenter.makeResultsMessage()
        
        let resultMessage = AlertModel(
            accessibilityId: "Game results",
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        )
        alertPresenter?.showGameResult(with: resultMessage)
        
    }
    
    /// метод меняет состояние кнопок
    func switchButton(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }
    
    /// метод, который меняет цвет рамки
    func highlightImageBorder(isCorrectAnswer: Bool) {
        switchButton(state: false)
        
        /// метод красит рамку
        imageView.layer.borderWidth = 8
        if isCorrectAnswer {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func presentAlert(model: AlertModel?) {
        self.present(self, animated: true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let resultMessage = AlertModel(
            accessibilityId: "Network Error",
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        )
        alertPresenter?.showGameResult(with: resultMessage)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
}

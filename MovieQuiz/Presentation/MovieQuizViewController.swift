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
        
//        print(NSHomeDirectory())
//        print(Bundle.main.bundlePath)
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(docs.scheme!)
        if #available(iOS 16.0, *) {
            print(docs.path(percentEncoded: true))
        } else {
            // Fallback on earlier versions
            print(docs.path)
        }
        
        let fileManager = FileManager.default
        guard var docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        docs.appendPathComponent("top250MoviesIMDB.json")
        
        var jsonString = ""
        jsonString = try! fileManager.fileExists(atPath: docs.path) ? String(contentsOf: docs) : ""
        
        if let top = getMovie(from: jsonString) {
            let dbItems = top.items[0]
            
            print(dbItems.crew)
        }
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        questionFactory = QuestionFactory(delegate: self)
        
//        if let firstQuestion = questionFactory.requestNextQuestion() {
//            currentQuestion = firstQuestion
//            let viewModel = convert(model: firstQuestion)
//            show(quiz: viewModel)
//        }
        questionFactory?.requestNextQuestion()
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
    
    private func showGameReault(quiz result: QuizResultsViewModel) {
        let resultsAlert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default){ [weak self] _ in
            // код, который сбрасывает игру и показывает первый вопрос
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        resultsAlert.addAction(action)
        
        self.present(resultsAlert, animated: true, completion: nil)
        
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            let message = "Ваш результат: \(correctAnswers)/\(questionsAmount) очков\n"
                        + "Средняя точность: \(Float(correctAnswers) * 100 / 10)%"
            
            let resultMessage = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз"
            )
            
            showGameReault(quiz: resultMessage)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
//            if let nextQuestion = questionFactory.requestNextQuestion() {
//                currentQuestion = nextQuestion
//                let viewModel = convert(model: nextQuestion)
//
//                show(quiz: viewModel)
//            }
            
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



/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */

//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import UIKit

class AlertPresenter: UIViewController, AlertPresenterProtocol {
    
    private weak var mainViewController: UIViewController?
    
    func showGameResult(with model: AlertModel?) {
        guard let mainController = mainViewController,
              let model = model else {
                return
        }
        
        let resultsAlert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        resultsAlert.view.accessibilityIdentifier = model.accessibilityId
        
        let action = UIAlertAction(title: model.buttonText, style: .default) {
            UIAlertAction in
            model.completion()
        }
        
        resultsAlert.addAction(action)
        
        mainController.present(resultsAlert, animated: true, completion: nil)
    }
    
    init(mainViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        self.mainViewController = mainViewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

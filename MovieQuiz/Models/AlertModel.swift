//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation

/// Модель алерта
struct AlertModel {
    /// ID для тестов
    let accessibilityId: String
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}

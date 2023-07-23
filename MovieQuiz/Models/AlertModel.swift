//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Alexandr on 21.06.2023.
//

import Foundation

struct AlertModel {
    let accessibilityId: String
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}

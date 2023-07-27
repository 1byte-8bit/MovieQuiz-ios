//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Alexandr on 20.07.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    
    func testYesButton() {
        sleep(5)
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        
        sleep(5)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        // проверяем, что постеры разные
        XCTAssertFalse(firstPosterData == secondPosterData)
        
        // Проверяем, что лейбл равен заданному формату
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData) // проверяем, что постеры разные
        // Проверяем, что лейбл равен заданному формату
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(3)
        
        let yesButton = app.buttons["Yes"]
        
        (1...10).forEach { _ in
            yesButton.tap()
                sleep(2)
            }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        
        let alertBtnText = alert.buttons.firstMatch.label
        XCTAssertEqual(alertBtnText, "Сыграть еще раз")
    }

    
    func testAlertDismiss() {
        sleep(3)
        
        let noButton = app.buttons["No"]
        
        (1...10).forEach { _ in
            noButton.tap()
                sleep(2)
            }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

}

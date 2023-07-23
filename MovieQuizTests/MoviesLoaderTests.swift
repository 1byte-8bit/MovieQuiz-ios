//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Alexandr on 19.07.2023.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        // Then
        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                // давайте проверим, что пришло, например, два фильма — ведь в тестовых данных их всего два
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        // Then
        loader.loadMovies { result in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                case .success(_):
                    XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}

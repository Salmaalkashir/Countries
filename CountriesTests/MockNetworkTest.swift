//
//  MockNetworkTest.swift
//  CountriesTests
//
//  Created by Salma Alkashir on 25/03/2025.
//

import XCTest

final class MockNetworkTest: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
    func testFetchCountries() {
        let mockLoader = MockCountriesLoader()
        
        mockLoader.fetchCountries { result in
            switch result {
            case .success(let countries):
                XCTAssertNotNil(countries)
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error)")
            }
        }
    }

}

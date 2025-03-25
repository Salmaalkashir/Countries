//
//  CountriesTests.swift
//  CountriesTests
//
//  Created by Salma Alkashir on 23/03/2025.
//

import XCTest
@testable import Countries

final class CountriesTests: XCTestCase {
    let network: CountriesLoader = CountriesRemoteLoader()
    
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
    
    func testNetworkLayer() {
        let expectation = self.expectation(description: "Fetching countries..")
        
        network.fetchCountries { result in
            switch result {
            case .success(let countries):
                XCTAssertNotEqual(countries.count, 0, "API Failed, No Data")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Network request failed with error: \(error)")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}



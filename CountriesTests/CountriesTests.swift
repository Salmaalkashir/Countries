//
//  CountriesTests.swift
//  CountriesTests
//
//  Created by Salma Alkashir on 23/03/2025.
//

import XCTest
@testable import Countries

class CountriesTests: XCTestCase {
  
  func testFetchCountriesSuccess() {
    let mockLoader = MockCountriesLoader()
    
    mockLoader.fetchCountries { result in
      switch result {
      case .success(let countries):
        XCTAssertNotNil(countries)
        XCTAssertGreaterThan(countries.count, 0, "Expected countries but got an empty list")
      case .failure(let error):
        XCTFail("Expected success, but got error: \(error)")
      }
    }
  }
  
  func testFetchCountriesWithEmptyResponse() {
    let mockLoader = MockCountriesLoader()
    mockLoader.mockResponse = "[]" 
    
    mockLoader.fetchCountries { result in
      switch result {
      case .success(let countries):
        XCTAssertEqual(countries.count, 0, "Expected empty array but got data")
      case .failure:
        XCTFail("Expected success with empty array but got failure")
      }
    }
  }
  
  func testFetchCountriesWithInvalidJSON() {
    let mockLoader = MockCountriesLoader()
    mockLoader.mockResponse = "{ invalid json }"
    
    mockLoader.fetchCountries { result in
      switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .failure(let error):
        XCTAssertNotNil(error, "Expected decoding failure but got nil")
      }
    }
  }
  
  func testFetchCountriesWithFailure() {
    let mockLoader = MockCountriesLoader()
    mockLoader.shouldFail = true
    
    mockLoader.fetchCountries { result in
      switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .failure(let error):
        XCTAssertNotNil(error, "Expected failure but got nil")
      }
    }
  }
  
  func testCountryModelDecoding() {
    let json = """
        {
            "name": "France",
            "alpha2Code": "FR",
            "capital": "Paris",
            "region": "Europe",
            "population": 67081000,
            "flag": "https://upload.wikimedia.org/wikipedia/en/c/c3/Flag_of_France.svg"
        }
        """
    
    let data = Data(json.utf8)
    let decoder = JSONDecoder()
    
    do {
      let country = try decoder.decode(CountryModel.self, from: data)
      XCTAssertEqual(country.name, "France")
      XCTAssertEqual(country.alpha2Code, "FR")
      XCTAssertEqual(country.capital, "Paris")
    } catch {
      XCTFail("Decoding failed with error: \(error)")
    }
  }
}


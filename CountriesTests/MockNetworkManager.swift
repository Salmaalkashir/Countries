//
//  MockNetworkManager.swift
//  CountriesTests
//
//  Created by Salma Alkashir on 25/03/2025.
//

import Foundation
@testable import Countries
class MockCountriesLoader: CountriesLoader {
     let mockResponse: String = """
    [
        {
            "name": "Afghanistan",
            "alpha2Code": "AF",
            "capital": "Kabul",
            "region": "Asia",
            "population": 40218234,
            "flag": "https://upload.wikimedia.org/wikipedia/commons/5/5c/Flag_of_the_Taliban.svg"
        },
        {
            "name": "Germany",
            "alpha2Code": "DE",
            "capital": "Berlin",
            "region": "Europe",
            "population": 83190556,
            "flag": "https://upload.wikimedia.org/wikipedia/en/b/ba/Flag_of_Germany.svg"
        }
    ]
    """

    func fetchCountries(completion: @escaping Completion<[CountryModel]>) {
        let data = Data(mockResponse.utf8)
        do {
            let countries = try JSONDecoder().decode([CountryModel].self, from: data)
            completion(.success(countries))
        } catch {
            completion(.failure(NetworkError.decodingFailed(error)))
        }
    }
}

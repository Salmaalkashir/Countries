//
//  Repository.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
final class Repository {
  private let dataSource: CountriesLoader
  
  init(dataSource: CountriesLoader) {
    self.dataSource = dataSource
  }
  
  func fetchCountries(completion: @escaping Completion<[CountryModel]>) {
    dataSource.fetchCountries(completion: completion)
  }
}

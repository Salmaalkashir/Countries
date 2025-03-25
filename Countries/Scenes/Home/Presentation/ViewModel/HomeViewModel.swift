//
//  HomeViewModel.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
class HomeViewModel {
  private let repository: Repository
  
  init(repository: Repository) {
    self.repository = repository
  }
  
  var bindCountries: (()->()) = {}
  
  var retrievedCountries: [CountryModel]? {
    didSet {
      bindCountries()
    }
  }
  
  var bindFailure: ((NetworkError) -> Void)?

  
  func getCountries() {
    repository.fetchCountries { [weak self] result in
      switch result {
      case .success(let success):
        self?.retrievedCountries = success
        
      case .failure(let error):
        print("ERR:\(error)")
        self?.bindFailure?(error)
      }
    }
  }
  
  func getMyCountry() -> CountryModel? {
    for myCountry in retrievedCountries ?? [] {
      if myCountry.alpha2Code == UserDefaults.standard.value(forKey: "countryCode") as? String {
        return myCountry
      }
    }
    
    return nil
  }
}

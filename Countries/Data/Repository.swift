//
//  Repository.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
import CoreData
final class Repository {
  private let dataSource: CountriesLoader
  private let coreData: CoreDataManagerProtocol = CoreDataManager.getObj()
  
  init(dataSource: CountriesLoader) {
    self.dataSource = dataSource
  }
  
  func fetchCountries(completion: @escaping Completion<[CountryModel]>) {
    dataSource.fetchCountries(completion: completion)
  }
  
  func saveCountriesToCoreData(country: CountryModel) {
    coreData.SaveCountryCoreData(country: country) 
  }
  
  func fetchCountriesFromCoreData() -> [NSManagedObject] {
    coreData.fetchCountries()
  }
}

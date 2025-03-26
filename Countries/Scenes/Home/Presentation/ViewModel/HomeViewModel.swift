//
//  HomeViewModel.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
import CoreData
import CoreLocation

protocol HomeViewModelProtocol {
  var bindCountries: (()->()) {get set}
  var bindFailure: ((NetworkError) -> Void)? {get set}
  var retrievedCountries: [CountryModel]? {get set}
  func getCountries()
  func getMyCountry() -> CountryModel?
  var bindInternetIssue: (()->()) {get set}
  var internetIssueError: NetworkError? {get set}
  func retrieveCountriesFromCoreData() -> [NSManagedObject]
  func getMyCountryFromCoreData() -> NSManagedObject?
  var filteredCountries: [CountryModel] {get set}
  var filteredCoreDataCountries: [NSManagedObject] {get set}
  func updateFilteredCountries(with searchText: String)
  func fetchCountryCode(from coordinates: CLLocationCoordinate2D)
  func handleLocationAuthorization(status: CLAuthorizationStatus)
  var isOffline: Bool {get set}
  func getCountriesCount() -> Int
  var addedCountries: [CountryModel] {get set}
  var coreDataAddedCountries: [NSManagedObject] {get set}
  func getAddedCountriesCount() -> Int
  var myCountryRemote: CountryModel? {get set}
  var myCountryCoreData: NSManagedObject? {get set}
  func getCountriesImage(index: Int) -> String
  func getCountriesName(index: Int) -> String
  func getFilteredCountriesName(index: Int) -> String
  func getFilteredCountriesImage(index: Int) -> String 
}

final class HomeViewModel: HomeViewModelProtocol {
 
  private let repository: Repository
  
  init(repository: Repository) {
    self.repository = repository
  }
  
  //MARK: - Get Countries
  var bindCountries: (()->()) = {}
  
  var retrievedCountries: [CountryModel]? {
    didSet {
      bindCountries()
    }
  }
  
  var bindFailure: ((NetworkError) -> Void)?
  
  var bindInternetIssue: (() -> ()) = {}
  var internetIssueError: NetworkError?

  func getCountries() {
    repository.fetchCountries { [weak self] result in
      switch result {
      case .success(let success):
        self?.retrievedCountries = success
        for country in success {
          self?.repository.saveCountriesToCoreData(country: country)
        }
      case .failure(let error):
        self?.bindFailure?(error)
      }
    }
  }
  
  func retrieveCountriesFromCoreData() -> [NSManagedObject] {
    repository.fetchCountriesFromCoreData()
  }
  
  var isOffline: Bool = false
  
  func getCountriesCount() -> Int {
    return isOffline == false ? filteredCountries.count : filteredCoreDataCountries.count
  }
  
  var addedCountries: [CountryModel] = []
  var coreDataAddedCountries: [NSManagedObject] = []
  
  func getAddedCountriesCount() -> Int {
    return isOffline == false ? addedCountries.count : coreDataAddedCountries.count
  }
  
  func getCountriesImage(index: Int) -> String {
    return isOffline == false ? addedCountries[index].flags?.png ?? "" : ""
  }
  
  func getCountriesName(index: Int) -> String {
    return isOffline == false ? addedCountries[index].name ?? "" : coreDataAddedCountries[index].value(forKey: "name") as? String ?? ""
  }
  
  func getAddedCountry(at index: Int) -> Any {
    return isOffline == false ? addedCountries[index] : coreDataAddedCountries[index]
  }
  
  //MARK: - CoreLocation
  func fetchCountryCode(from coordinates: CLLocationCoordinate2D) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    
    geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
      if let error = error {
       print("error")
        return
      }
      
      guard let countryCode = placemarks?.first?.isoCountryCode else { return }
      print("Country Code: \(countryCode)")
    }
  }

  func handleLocationAuthorization(status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      print("Location access authorized")
    case .denied, .restricted:
      print("Location access denied")
      if let countryCode = Locale.current.region?.identifier {
        
        UserDefaults.standard.set(countryCode, forKey: "countryCode")
        self.getCountries()
        print("Device Country Code Home: \(countryCode)")
      }
    case .notDetermined:
      print("Location access not determined")
    @unknown default:
      print("Unexpected authorization status")
    }
  }
  
  //MARK: - Searching in Countries
  var filteredCountries: [CountryModel] = []
  var filteredCoreDataCountries: [NSManagedObject] = []
  
  func updateFilteredCountries(with searchText: String) {
    filteredCountries.removeAll()
    filteredCoreDataCountries.removeAll()
    
    guard !searchText.isEmpty else {
      if isOffline {
        filteredCoreDataCountries = retrieveCountriesFromCoreData()
      } else {
        filteredCountries = retrievedCountries ?? []
      }
      return
    }
    
    if isOffline {
      filteredCoreDataCountries = retrieveCountriesFromCoreData().filter {
        ($0.value(forKey: "name") as? String ?? "").uppercased().contains(searchText.uppercased())
      }
    } else {
      filteredCountries = (retrievedCountries ?? []).filter {
        ($0.name ?? "").uppercased().contains(searchText.uppercased())
      }
    }
  }
  
  func getFilteredCountriesImage(index: Int) -> String {
    return isOffline == false ? filteredCountries[index].flags?.png ?? "" : ""
  }
  
  func getFilteredCountriesName(index: Int) -> String {
    return isOffline == false ? filteredCountries[index].name ?? "" : filteredCoreDataCountries[index].value(forKey: "name") as? String ?? ""
  }
  
  
  //MARK: - My Country
  
  var myCountryRemote: CountryModel?
  var myCountryCoreData: NSManagedObject?
  
  func getMyCountry() -> CountryModel? {
    for myCountry in retrievedCountries ?? [] {
      if myCountry.alpha2Code == UserDefaults.standard.value(forKey: "countryCode") as? String {
        myCountryRemote = myCountry
        return myCountry
      }
    }
    return nil
  }
  
  func getMyCountryFromCoreData() -> NSManagedObject? {
    for myCountry in retrieveCountriesFromCoreData() {
      if myCountry.value(forKey: "alpha2Code") as? String == UserDefaults.standard.value(forKey: "countryCode") as? String  {
        myCountryCoreData = myCountry
        return myCountry
      }
    }
    return nil
  }
}

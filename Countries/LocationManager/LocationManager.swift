//
//  LocationManager.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
  static let shared = LocationManager()
  
  private let locationManager = CLLocationManager()
  var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
  var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
  
  private override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  func requestLocationPermission() {
    let status = locationManager.authorizationStatus
    
    switch status {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager.requestLocation()
    case .denied, .restricted:
      if let countryCode = Locale.current.region?.identifier {
       
        print("Device Country Code: \(countryCode)")
      }
    @unknown default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      onLocationUpdate?(location.coordinate)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    onAuthorizationChange?(manager.authorizationStatus)
    
    if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
      locationManager.requestLocation()
    }
  }
  
  func getCountryCode(from latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
      let geocoder = CLGeocoder()
      let location = CLLocation(latitude: latitude, longitude: longitude)

      geocoder.reverseGeocodeLocation(location) { placemarks, error in
          if let error = error {
              print("Reverse geocoding error: \(error.localizedDescription)")
              completion(nil)
              return
          }

          if let countryCode = placemarks?.first?.isoCountryCode {
              completion(countryCode)
          } else {
              completion(nil)
          }
      }
  }
}


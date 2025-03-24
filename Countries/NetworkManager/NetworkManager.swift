//
//  NetworkManager.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation


protocol CountriesLoader {
  func fetchCountries(completion: @escaping Completion<[CountryModel]>)
}

final class CountriesRemoteLoader: CountriesLoader {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  
  func fetchCountries(completion: @escaping Completion<[CountryModel]>) {
    guard let url = URL(string: "https://restcountries.com/v2/all") else {
      completion(.failure(NetworkError.invalidURL))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(NetworkError.requestFailed(error)))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(NetworkError.invalidResponse))
        return
      }
      
      guard (200..<300).contains(httpResponse.statusCode) else {
        completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
        return
      }
      
      guard let data = data else {
        completion(.failure(NetworkError.noData))
        return
      }
      
      do {
        let decodedObject = try JSONDecoder().decode([CountryModel].self, from: data)
        completion(.success(decodedObject))
      } catch {
        completion(.failure(NetworkError.decodingFailed(error)))
      }
    }
    
    task.resume()
  }
}

public enum NetworkError: Error {
  case invalidURL
  case requestFailed(Error)
  case invalidResponse
  case noData
  case httpError(statusCode: Int)
  case decodingFailed(Error)
  
  var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "The URL provided is invalid."
    case .requestFailed(let error):
      return "The request failed with error: \(error.localizedDescription)"
    case .invalidResponse:
      return "Received an invalid response from the server."
    case .noData:
      return "No data was received from the server."
    case .httpError(let statusCode):
      return "Received an HTTP error with status code: \(statusCode)"
    case .decodingFailed:
      return "Failed to decode response"
    }
  }
}


public typealias Completion<T> = (_ result: Result<T, NetworkError>) -> Void

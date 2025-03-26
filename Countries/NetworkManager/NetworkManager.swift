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
      if let error = error as NSError? {
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
          print("Internet connection appears to be offline.")
          completion(.failure(.internetIssue))
          return
        case NSURLErrorTimedOut:
          print("Request timed out.")
          completion(.failure(.internetIssue))
          return
        case NSURLErrorNetworkConnectionLost:
          print("Network connection was lost.")
          completion(.failure(.internetIssue))
          return
        default:
          completion(.failure(.requestFailed))
          return
        }
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

public enum NetworkError: Error, Equatable {
    case invalidResponse
    case invalidURL
    case requestFailed
    case decodingFailed(Error)
    case internetIssue
    case noData
    case httpError(statusCode: Int)

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.invalidURL, .invalidURL),
             (.requestFailed, .requestFailed),
          (.internetIssue, .internetIssue):
            return true
        case let (.httpError(code1), .httpError(code2)):
            return code1 == code2
        case let (.decodingFailed(error1), .decodingFailed(error2)):
            return (error1 as NSError).domain == (error2 as NSError).domain
        default:
            return false
        }
    }

  var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "The URL provided is invalid."
    case .requestFailed:
      return "The request failed with error"
    case .invalidResponse:
      return "Received an invalid response from the server."
    case .noData:
      return "No data was received from the server."
    case .httpError(let statusCode):
      return "Received an HTTP error with status code: \(statusCode)"
    case .decodingFailed:
      return "Failed to decode response"
    case .internetIssue:
      return "Network Connection error"
    }
  }
}

public typealias Completion<T> = (_ result: Result<T, NetworkError>) -> Void

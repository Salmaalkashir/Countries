//
//  CountriesModel.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
struct CountryModel: Decodable {
  let name: String?
  let alpha2Code: String?
  let capital: String?
  let region: String?
  let population: Int?
  let flags: Flags?
  let currencies: [Currency]?
}

struct Flags: Decodable {
  let svg,png: String?
}

struct Currency: Codable {
  let code, name, symbol: String?
}



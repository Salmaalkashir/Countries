//
//  CountriesModel.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import Foundation
struct CountryModel: Decodable {
    let name: String?
    let topLevelDomain: [String]?
    let alpha2Code, alpha3Code: String?
    let callingCodes: [String]?
    let capital: String?
    let altSpellings: [String]?
    let subregion: String?
    let region: String?
    let population: Int?
    let latlng: [Double]?
    let demonym: String?
    let area: Double?
    let timezones: [String]?
    let borders: [String]?
    let nativeName, numericCode: String?
    let flags: Flags?
    let currencies: [Currency]?
    let languages: [Language]?
    let translations: Translations?
    let flag: String?
    let regionalBlocs: [RegionalBloc]?
    let cioc: String?
    let independent: Bool?
    let gini: Double?
}

struct Flags: Decodable {
    let svg,png: String
}

struct Currency: Codable {
    let code, name, symbol: String
}
struct Language: Decodable {
    let iso6391: String?
    let iso6392, name: String
    let nativeName: String?

    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso639_1"
        case iso6392 = "iso639_2"
        case name, nativeName
    }
}
struct Translations: Decodable {
    let br, pt, nl, hr: String
    let fa: String?
    let de, es, fr, ja: String
    let it, hu: String
}


struct RegionalBloc: Decodable {
    let acronym: String
    let name: String
}

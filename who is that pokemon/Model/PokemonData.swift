//
//  PokemonData.swift
//  who is that pokemon
//
//  Created by Raúl Gallego Alonso on 01/09/2023.
//
import Foundation

// MARK: - PokemonData
struct PokemonData: Codable {
    let results: [Result]?
}

// MARK: - Result
struct Result: Codable {
    let name: String?
    let url: String?
}

//
//  URL+Extensions.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import Foundation

extension URL {
    
    static var development: URL {
        URL(string: "https://pokeapi.co")!
    }
    // "/api/v2/"
    
    static var allPokemons: URL {
        URL(string: "/api/v2/pokemon", relativeTo: Self.development)!
    }
    
    static func allPokemons(offset: Int = 0, limit: Int = 20) -> URL {
        var components = URLComponents(url: Self.development.appendingPathComponent("/api/v2/pokemon"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return components.url!
    }
        
    
    static func getPokemon(_ pokemonString: String) -> URL {
        return URL(string: pokemonString)!
    }
}

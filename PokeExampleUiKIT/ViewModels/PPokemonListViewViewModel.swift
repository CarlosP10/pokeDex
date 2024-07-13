//
//  PPokemonListViewViewModel.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import Foundation
import UIKit

protocol PPokemonListViewViewModelDelegate: AnyObject {
    func didLoadInitialPokemons()
    func didLoadMorePokemons(with newIndexPath: [IndexPath])
}

final class PPokemonListViewViewModel {
    
    @Published var pokemons: [PPokemonResults] = []
    @Published var pokemonDetails: [String: Pokemon] = [:]
    @Published var isLoadingMore = false
    public weak var delegate: PPokemonListViewViewModelDelegate?
    var apiNext: String? = nil
    private var pokemonsOffset = 0
    
    private var client = PEHttpClient()
    
    func loadPokemons() {
        isLoadingMore = true
        let resource = Resource<PResults>(url: URL.allPokemons)
        client.load(resource) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.pokemons = success.results
                    self.apiNext = success.next
                    self.isLoadingMore = false
                    self.pokemonsOffset+=20
                    self.delegate?.didLoadInitialPokemons()
                    print("First Next page URL:", self.pokemonsOffset ?? "None")
                }
            case .failure(let failure):
                print(String(describing: failure))
            }
        }
    }
    
    func loadMorePokemons() {
        isLoadingMore = true
        print(URL.allPokemons(offset: pokemonsOffset, limit: 20).absoluteString)
        let resource = Resource<PResults>(url: URL.allPokemons(offset: pokemonsOffset, limit: 20))
        client.load(resource) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    let startIndex = self.pokemons.count
                    self.pokemons.append(contentsOf: success.results)
                    let endIndex = self.pokemons.count
                    let newIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
                    self.pokemonsOffset+=20
                    // Update apiNext with the next URL from the response
                    self.apiNext = success.next
                    print("Previous apiNext: \(self.pokemonsOffset)")
                    print("Updated apiNext: \(self.apiNext ?? "None")")
                    
                    self.isLoadingMore = false
                    self.delegate?.didLoadMorePokemons(with: newIndexPaths)
                }
            case .failure(let failure):
                print("Error loading more pokemons: \(failure)")
                self.isLoadingMore = false
            }
        }
    }
    
    func loadPokemon(pokemonString: String) {
        let resource = Resource<Pokemon>(url: URL.getPokemon(pokemonString))
        client.load(resource) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.pokemonDetails[pokemonString] = success
                }
            case .failure(let failure):
                print(String(describing: failure))
            }
        }
        
    }
    
}

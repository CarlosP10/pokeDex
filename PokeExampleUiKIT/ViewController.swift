//
//  ViewController.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import Combine
import UIKit

class ViewController: UITableViewController {
    
    //MARK: UI
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private var viewModel = PPokemonListViewViewModel()
    private var cancellables = Set<AnyCancellable>() // Property to store cancellables
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Pokedex"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pokecell")
        //tableView.register(SpinnerTableViewCell.self, forCellReuseIdentifier: "spinnerCell")
        spinner.startAnimating()
        setUpView()
        viewModel.delegate = self
        Task {
            viewModel.loadPokemons()
        }
        //Check changes in pokemonDetails
        viewModel.$pokemonDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
            
    }
    
    private func setUpView() {
        //tableView.separatorStyle = .singleLine
        //tableView.isScrollEnabled = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemons.count//  + (viewModel.isLoadingMore ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == viewModel.pokemons.count && viewModel.isLoadingMore {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "spinnerCell", for: indexPath) as! SpinnerTableViewCell
//            cell.spinner.startAnimating()
//            return cell
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokecell", for: indexPath)
        cell.selectionStyle = .none
        let pokemonResult = viewModel.pokemons[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        
        configuration.secondaryText = "Loading..."
        
        if let pokemonDetail = viewModel.pokemonDetails[pokemonResult.url] {
            configuration.text = pokemonDetail.name.capitalized
            configuration.secondaryText = "Base Experience: \(pokemonDetail.base_experience)"
        
            if let url = URL(string: pokemonDetail.sprites.front_default) {
                cell.imageView?.loadImage(from: url.absoluteString) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            configuration.image = image
                            configuration.imageProperties.maximumSize = CGSize(width: 75, height: 75)
                            cell.contentConfiguration = configuration
                        }
                    }
                }
            }
        } else {
            Task {
                viewModel.loadPokemon(pokemonString: pokemonResult.url)
            }
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard !viewModel.pokemons.isEmpty,
                  !viewModel.isLoadingMore else { return }
            spinner.startAnimating()
            viewModel.loadMorePokemons()
        }
    }

}

extension ViewController: PPokemonListViewViewModelDelegate {
    func didLoadInitialPokemons() {
        self.spinner.stopAnimating()
        self.tableView.reloadData()
        
    }
    
    func didLoadMorePokemons(with newIndexPath: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPath, with: .automatic)
        }
        //tableView.reloadData()
        spinner.stopAnimating()
    }
    
    
}

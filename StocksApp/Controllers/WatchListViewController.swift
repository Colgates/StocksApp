//
//  ViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import UIKit

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTitleView()
        setUpChild()
    }
    
    // MARK: - Private
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    private func setUpTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)
        
        navigationItem.titleView = titleView
    }

    private func setUpChild() {

    }
}

// MARK: - UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
                let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
                !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return
                }
        
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let repsponse):
                    DispatchQueue.main.async {
                        resultsVC.update(with: repsponse.result)
                    }
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                }
            }
        })

    }
}

// MARK: - SearchResultsViewControllerDeleagate

extension WatchListViewController: SearchResultsViewControllerDeleagate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
//        navigationItem.searchController?.searchBar.resignFirstResponder()
        let navVC = UINavigationController(rootViewController: StockDetailsViewController())
        present(navVC, animated: true)
    }
}

//
//  ViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import FloatingPanel
import UIKit

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    private var watchlistMap: [String : [String]] = [:]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.isHidden = true
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        setUpWatchlistData()
        setUpTitleView()
        setUpFloatingPanel()
    }
    
    // MARK: - Private
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    private func setUpTableView() {
        view.addSubviews(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setUpWatchlistData() {
        let symbols = PersistenceManager.shared.watchList
        
        for symbol in symbols {
            watchlistMap[symbol] = ["some string"]
        }
        
        tableView.reloadData()
    }
    
    private func setUpTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)
        
        navigationItem.titleView = titleView
    }

    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .company(symbol: "SNAP"))
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
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

// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
        navigationItem.searchController?.searchBar.isHidden = fpc.state == .full
    }
}

// MARK: - UITableViewDataSource

extension WatchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        results.count
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
//        let model = results[indexPath.row]
//        var configuration = cell.defaultContentConfiguration()
//        configuration.text = model.displaySymbol
//        configuration.secondaryText = model.description
//        cell.contentConfiguration = configuration
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WatchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let model = results[indexPath.row]
//        delegate?.searchResultsViewControllerDidSelect(searchResult: model)
    }
}

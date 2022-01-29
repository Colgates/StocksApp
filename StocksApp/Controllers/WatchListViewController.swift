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
    
    private var watchlistMap: [String : [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
        
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                self?.createViewModels()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(
                symbol: symbol,
                companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                price: getLatestClosingPrice(from: candleSticks),
                changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                changePercentage: .percentage(from: changePercentage),
                chartViewModel: .init(
                    data: candleSticks.reversed().map { $0.close },
                    showLegend: false,
                    showAxis: false)
            ))
        }
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close, let priorClose = data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate) })?.close else {
            return 0
        }
        print(priorClose)
        print(latestClose)
        let diff = 1 - (priorClose/latestClose)
        return diff
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return .formatted(number: closingPrice)
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
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else { fatalError() }
        cell.configure(with: viewModels[indexPath.row])
        cell.backgroundColor = .red
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WatchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        WatchListTableViewCell.preferredHeight
    }
    
    
}

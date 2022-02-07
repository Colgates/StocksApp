//
//  StockDetailsViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import UIKit

class StockDetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.sectionHeaderTopPadding = 0
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return tableView
    }()
    
    private var candleStickData: [CandleStick]
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick]) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        
        setUpTableView()
        setUpCloseButton()
        fetchFinancialData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height / 2))
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            Task {
                defer { group.leave() }
                let response = try await APICaller.shared.marketData(for: symbol)
                candleStickData = response.candleSticks
            }
        }
        
        group.enter()
        Task {
            defer { group.leave() }
            let response = try await APICaller.shared.financialMetrics(for: symbol)
            let metrics = response.metric
            self.metrics = metrics
        }
        
        group.enter()
        Task {
            defer { group.leave() }
            
            let stories = try await APICaller.shared.news(for: .company(symbol: symbol))
            self.stories = stories
            self.tableView.reloadData()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    private func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height / 2))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: String(metrics.annualWeekHigh)))
            viewModels.append(.init(name: "52W Low", value: String(metrics.annualWeekLow)))
            viewModels.append(.init(name: "52W Return", value: String(metrics.annualWeekPriceReturnDaily)))
            viewModels.append(.init(name: "10D Vol.", value: String(metrics.tenAverageTradingVolume)))
        }
        
        let changePercentage = getChangePercentage(data: candleStickData)
        
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map { $0.close }, showLegend: false, showAxis: true, fillColor: changePercentage < 0 ? .systemRed : .systemGreen), metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
// MARK: - UITableViewDataSource

extension StockDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else { fatalError() }
        cell.backgroundColor = .red
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
        header.delegate = self
        let shouldShowAddButton = !PersistenceManager.shared.watchlistContains(symbol: symbol)
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: shouldShowAddButton))
        return header
    }
}
// MARK: - UITableViewDelegate

extension StockDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        
        HapticsManager.shared.vibrateForSelection()
        
        presentSafariViewController(with: url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewsHeaderView.preferredHeight
    }
}
// MARK: - NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        
        HapticsManager.shared.vibrate(for: .success)
        
        headerView.addButton.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        
        let alert = UIAlertController(title: "Added to Watchlist", message: "We've added \(companyName) to your watchlist" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

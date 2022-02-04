//
//  StockDetailsViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import SafariServices
import UIKit

class StockDetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    
    private let tableView: UITableView = {
        let tableView = UITableView()
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
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let respone):
                    self.candleStickData = respone.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.enter()
        
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height * 0.4))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: String(metrics.annualWeekHigh)))
            viewModels.append(.init(name: "52W Low", value: String(metrics.annualWeekLow)))
            viewModels.append(.init(name: "52W Return", value: String(metrics.annualWeekPriceReturnDaily)))
            viewModels.append(.init(name: "10D Vol.", value: String(metrics.tenAverageTradingVolume)))
            viewModels.append(.init(name: "Beta", value: String(metrics.beta)))
        }
        let changePercentage = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map { $0.close }, showLegend: true, showAxis: true, fillColor: changePercentage < 0 ? .systemRed : .systemGreen), metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close, let priorClose = data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate) })?.close else {
            return 0
        }
        let diff = 1 - (priorClose/latestClose)
        return diff
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - UITableViewDataSource

extension StockDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else { fatalError() }
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
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
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
        
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)

        let alert = UIAlertController(title: "Added to Watchlist", message: "We've added \(companyName) to your watchlist" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

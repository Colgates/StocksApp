//
//  StockDetailsViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import UIKit

class StockDetailsViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, NewsStory>?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.sectionHeaderTopPadding = 0
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return tableView
    }()
    
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
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
        configureDataSource()
        setUpCloseButton()
        fetchFinancialData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height / 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            if self.metrics != nil {
                self.renderChart()
            }
        }
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }
    
    private func setUpTableView() {
        tableView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, NewsStory>(tableView: tableView, cellProvider: { tableView, indexPath, model in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else { fatalError() }
            cell.configure(with: .init(model: model))
            return cell
        })
    }
    
    private func updateDataSource(with viewModels: [NewsStory]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsStory>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource?.apply(snapshot, animatingDifferences: false)
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
            updateDataSource(with: stories)
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
        
        headerView.configure(chartViewModel: .init(data: candleStickData.map { $0.close }, showLegend: false, showAxis: true, fillColor: changePercentage < 0 ? .systemRed : .systemGreen), metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension StockDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let story = dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let url = URL(string: story.url) else { return }

        HapticsManager.shared.vibrateForSelection()

        presentSafariViewController(with: url)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
        header.delegate = self
        let shouldShowAddButton = !PersistenceManager.shared.watchlistContains(symbol: symbol)
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: shouldShowAddButton))
        return header
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

//
//  SearchResultsViewController.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import UIKit

protocol SearchResultsViewControllerDeleagate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultsViewControllerDeleagate?
    
    enum Section {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, SearchResult>?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        configureDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
            var configuration = cell.defaultContentConfiguration()
            configuration.text = model.displaySymbol
            configuration.secondaryText = model.description
            cell.contentConfiguration = configuration
            return cell
        })
    }
    
    func updateDataSource(with results: [SearchResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SearchResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(results)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    public func update(with results: [SearchResult]) {
        tableView.isHidden = results.isEmpty
        updateDataSource(with: results)
    }
}
// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
        delegate?.searchResultsViewControllerDidSelect(searchResult: model)
        dismiss(animated: true)
    }
}

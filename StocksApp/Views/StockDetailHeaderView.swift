//
//  StockDetailHeaderView.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 03.02.2022.
//

import UIKit
import SwiftUI

class StockDetailHeaderView: UIView {
    
    enum Section {
        case main
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, MetricCollectionViewCell.ViewModel>?
    
    private let chartView: StockChartView = {
        let chart = StockChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MetricCollectionViewCell.ViewModel>(collectionView: collectionView, cellProvider: { collectionView, indexPath, model in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier, for: indexPath) as? MetricCollectionViewCell else { fatalError() }
            cell.configure(with: model)
            return cell
        })
    }
    
    private func updateDataSource(with viewModels: [MetricCollectionViewCell.ViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MetricCollectionViewCell.ViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.topAnchor.constraint(equalTo: topAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: chartView.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(chartViewModel: StockChartView.ViewModel, metricViewModels: [MetricCollectionViewCell.ViewModel]) {
        chartView.configure(with: chartViewModel)
        updateDataSource(with: metricViewModels)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StockDetailHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: width / 3, height: width / 5)
    }
}

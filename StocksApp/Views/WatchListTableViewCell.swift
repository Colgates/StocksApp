//
//  WatchListTableViewCell.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 28.01.2022.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListTableViewCell"
    
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel: Hashable {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondarySystemBackground
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(symbolLabel, nameLabel, priceLabel, changeLabel, miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            symbolLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            symbolLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),

            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            miniChartView.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor),
            miniChartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            miniChartView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            miniChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            priceLabel.leadingAnchor.constraint(equalTo: miniChartView.trailingAnchor, constant: 5),
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            priceLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),

            changeLabel.leadingAnchor.constraint(equalTo: miniChartView.trailingAnchor, constant: 5),
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor),
            changeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            changeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}

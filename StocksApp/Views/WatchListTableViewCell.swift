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
    
    struct ViewModel {
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
        label.backgroundColor = .systemGreen
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.backgroundColor = .systemYellow
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(symbolLabel, nameLabel, priceLabel, changeLabel, miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        miniChartView.sizeToFit()
//        NSLayoutConstraint.activate([
//            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
//            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
//            symbolLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
//            symbolLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),
//
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
//            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor),
//            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
//            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5)
//        ])
//
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(x: separatorInset.left, y: yStart, width: symbolLabel.width, height: symbolLabel.height)
        nameLabel.frame = CGRect(x: separatorInset.left, y: symbolLabel.bottom, width: symbolLabel.width, height: symbolLabel.height)
        priceLabel.frame = CGRect(x: contentView.width - 10 - priceLabel.width, y: 0, width: priceLabel.width, height: priceLabel.height)
        changeLabel.frame = CGRect(x: contentView.width - 10 - changeLabel.width, y: priceLabel.bottom, width: changeLabel.width, height: changeLabel.height)
        miniChartView.frame = CGRect(x: priceLabel.left - (contentView.width/3) - 5, y: 6, width: contentView.width/3, height: contentView.height - 12)
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

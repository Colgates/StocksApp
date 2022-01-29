//
//  StockChartView.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 28.01.2022.
//

import UIKit

class StockChartView: UIView {

    struct ViewModel {
        let data: [CandleStick]
        let showLegend: Bool
        let showAxis: Bool
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func reset() {
        
    }
}

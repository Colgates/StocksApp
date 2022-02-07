//
//  MarketDataResponse.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 28.01.2022.
//

import Foundation

struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let status: String
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case high = "h"
        case low = "l"
        case status = "s"
        case timestamps = "t"
    }
    
    var candleSticks: [CandleStick] {
        var result: [CandleStick] = []
        
        for index in 0..<open.count {
            result.append(CandleStick(date: Date(timeIntervalSince1970: timestamps[index]), high: high[index], low: low[index], open: open[index], close: close[index]))
        }
        return result.sorted { $0.date < $1.date }
    }
}

struct CandleStick {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}

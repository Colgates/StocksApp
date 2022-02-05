//
//  FinancialMetricsResponse.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 03.02.2022.
//

import Foundation

struct FinancialMetricsResponse: Codable {
    let metric: Metrics
}

struct Metrics: Codable {
    let tenAverageTradingVolume: Float
    let annualWeekHigh: Double
    let annualWeekLow: Double
    let annualWeekLowDate: String
    let annualWeekPriceReturnDaily: Float
    
    enum CodingKeys: String, CodingKey {
        case tenAverageTradingVolume = "10DayAverageTradingVolume"
        case annualWeekHigh = "52WeekHigh"
        case annualWeekLow = "52WeekLow"
        case annualWeekLowDate = "52WeekLowDate"
        case annualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
    }
}

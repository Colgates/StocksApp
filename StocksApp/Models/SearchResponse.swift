//
//  SearchResponse.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 27.01.2022.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable, Hashable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

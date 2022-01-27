//
//  PersistenceManager.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    private init() {}
    
    // MARK: - Public
    
    var watchList: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
    
    // MARK: - Private
    
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setUpDefaults() {
        let map: [String : String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inch.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
    }
}

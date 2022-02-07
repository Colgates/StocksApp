//
//  APICaller.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let apiKey = "c7osatiad3i94t1irtpg"
        static let sandboxApiKey = "sandbox_c7osatiad3i94t1irtq0"
        static let baseURL = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    // MARK: - Public

    public func search(query: String) async throws -> SearchResponse {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw APIError.invalidURL }
        return try await asyncRequest(url: url(for: .search, queryParams: ["q" : safeQuery]), expecting: SearchResponse.self)
    }

    public func news(for type: NewsViewController.`Type`) async throws -> [NewsStory] {
        switch type {
        case .topStories:
            return try await asyncRequest(url: url(for: .topStories, queryParams: ["category" : "general"]), expecting: [NewsStory].self)
        case .company(let symbol):
            
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(3600 * 24 * 7))
            
            let url = url(for: .companyNews, queryParams: [
                "symbol" : symbol,
                "from" : DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                "to" : DateFormatter.newsDateFormatter.string(from: today)])
            
            return try await asyncRequest(url: url, expecting: [NewsStory].self)
        }
    }

    public func marketData(for symbol: String) async throws -> MarketDataResponse {
        
        let today = Date()
        let weekBefore = today.addingTimeInterval(-(3600 * 24 * 5))
        
        let url = url(for: .marketData, queryParams: [
            "symbol" : symbol,
            "resolution" : "60",
            "from" : String(Int(weekBefore.timeIntervalSince1970)),
            "to" : String(Int(today.timeIntervalSince1970))
        ])
        
        return try await asyncRequest(url: url, expecting: MarketDataResponse.self)
    }

    public func financialMetrics(for symbol: String) async throws -> FinancialMetricsResponse {
        let url = url(for: .financials, queryParams: ["symbol" : symbol, "metric" : "all"])
        return try await asyncRequest(url: url, expecting: FinancialMetricsResponse.self)
    }
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case invalidURL
        case noDataReturned
    }
    
    private func url(for endpoint: Endpoint, queryParams: [String: String]) -> URL? {
        var urlString = Constants.baseURL + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        return URL(string: urlString)
    }

    private func asyncRequest<T: Codable>(url: URL?, expecting: T.Type) async throws -> T {
        guard let url = url else { throw APIError.invalidURL }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(expecting.self, from: data)
        } catch {
            throw(error)
        }
    }
}

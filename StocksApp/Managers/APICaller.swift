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
//    completion: @escaping (Result<SearchResponse, Error>) -> Void
    public func search(query: String) async throws -> SearchResponse {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw APIError.invalidURL }
//        request(url: url(for: .search, queryParams: ["q" : safeQuery]), expecting: SearchResponse.self, completion: completion)
        return try await asyncRequest(url: url(for: .search, queryParams: ["q" : safeQuery]), expecting: SearchResponse.self)
    }
    
    public func news(for type: NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        switch type {
        case .topStories:
            request(url: url(for: .topStories, queryParams: ["category" : "general"]), expecting: [NewsStory].self, completion: completion)
        case .company(let symbol):
            
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(3600 * 24 * 7))
            
            let url = url(for: .companyNews, queryParams: [
                "symbol" : symbol,
                "from" : DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                "to" : DateFormatter.newsDateFormatter.string(from: today)])
            
            request(url: url, expecting: [NewsStory].self, completion: completion)
        }
    }
    
    public func marketData(for symbol: String, completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
        
        let today = Date()
        let weekBefore = today.addingTimeInterval(-(3600 * 24 * 5))
        
        let url = url(for: .marketData, queryParams: [
            "symbol" : symbol,
            "resolution" : "60",
            "from" : String(Int(weekBefore.timeIntervalSince1970)),
            "to" : String(Int(today.timeIntervalSince1970))
        ])
        request(url: url, expecting: MarketDataResponse.self, completion: completion)
    }
    
    public func financialMetrics(for symbol: String, completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void) {
        let url = url(for: .financials, queryParams: ["symbol" : symbol, "metric" : "all"])
        request(url: url, expecting: FinancialMetricsResponse.self, completion: completion)
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
    
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    private func asyncRequest<T: Codable>(url: URL?, expecting: T.Type) async throws -> T {
        guard let url = url else { throw APIError.invalidURL }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(expecting.self, from: data)
            return result
        } catch {
            throw(error)
        }
        
        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                if let error = error {
//                    throw Error(error)
//                } else {
//                    throw APIError.noDataReturned
//                }
//            }
//
//            do {
//                let result = try JSONDecoder().decode(expecting.self, from: data)
//                completion(.success(result))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        .resume()
    }
}

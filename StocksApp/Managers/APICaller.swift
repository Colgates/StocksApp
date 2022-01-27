//
//  APICaller.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import Foundation
import SwiftUI

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let apiKey = "c7osatiad3i94t1irtpg"
        static let sandboxApiKey = "sandbox_c7osatiad3i94t1irtq0"
        static let baseURL = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    // MARK: - Public
    
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(for: .search, queryParams: ["q" : safeQuery]), expecting: SearchResponse.self, completion: completion)
    }
    
    public func news(for type: NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        switch type {
        case .topStories:
            request(url: url(for: .topStories, queryParams: ["category" : "general"]), expecting: [NewsStory].self, completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(3600 * 24 * 7))
            request(url: url(for: .companyNews, queryParams: [
                "symbol" : symbol,
                "from" : DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                "to" : DateFormatter.newsDateFormatter.string(from: today)]),
                    expecting: [NewsStory].self,
                    completion: completion)
        }
    }
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
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
//        print("\n\(urlString)\n")
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
}

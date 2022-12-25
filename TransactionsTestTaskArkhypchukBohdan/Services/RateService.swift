//
//  RateService.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 25.12.2022.
//

import Foundation


class RateService {
    
    private let host : URL
    private var session = URLSession.shared
    
    init(url: String) throws {
        if let url = URL(string: url) {
            self.host = url
            return
        }
        
        throw NetworkError.badHostString
    }
    
    func perform() async throws -> Data {
        let request = URLRequest(url: host)
        let (data, _) = try await session.data(for: request)
        return data
    }
}


struct RateData: Codable {
    
    struct BPI: Codable {
        var usd: USD = USD()
        
        enum CodingKeys: String, CodingKey {
            case usd = "USD"
        }
    }

    struct USD: Codable {
        var rate: String = ""
    }
    
    var bpi: BPI = BPI()

    func getRate() async -> String? {
        do {
            let rateService = try RateService(url: C.Strings.url)
            let data = try await rateService.perform()
            let results = try JSONDecoder().decode(RateData.self, from: data)
            
            return results.bpi.usd.rate
            
        } catch {
            print(error)
        }
        return nil
    }
}


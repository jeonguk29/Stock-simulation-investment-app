//
//  MockStocksAPI.swift
//  TradeUp
//
//  Created by MAC on 7/17/25.
//

import Foundation
import StocksAPI

#if DEBUG
struct MockStocksAPI: StockRepository {
    
    var stubbedSearchTickersCallback: (() async throws -> [Ticker])!
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker] {
        try await stubbedSearchTickersCallback()
    }
    
    var stubbedFetchQuotesCallback: (() async throws -> [Quote])!
    func fetchQuotes(symbols: String) async throws -> [Quote] {
        try await stubbedFetchQuotesCallback()
    }
    
}
#endif

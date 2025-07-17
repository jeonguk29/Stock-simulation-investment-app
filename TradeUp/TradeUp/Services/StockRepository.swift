//
//  StocksAPI.swift
//  TradeUp
//
//  Created by MAC on 7/17/25.
//

import Foundation
import StocksAPI

protocol StockRepository {
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
}

extension StocksAPI: StockRepository {}

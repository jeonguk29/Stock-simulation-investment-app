//
//  MockTickerListRepository.swift
//  TradeUp
//
//  Created by MAC on 7/23/25.
//

import Foundation
import StocksAPI

#if DEBUG
struct MockTickerListRepository: TickerListRepository {
    
    var stubbedLoad: (() async throws -> [Ticker])!
    
    func load() async throws -> [Ticker] {
        try await stubbedLoad()
    }
    
    func save(_ current: [Ticker]) async throws {}
    
}
#endif

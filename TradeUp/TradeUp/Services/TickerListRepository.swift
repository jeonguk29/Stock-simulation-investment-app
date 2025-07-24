//
//  TickerListRepository.swift
//  TradeUp
//
//  Created by MAC on 7/23/25.
//

import Foundation
import StocksAPI

protocol TickerListRepository {
    func save(_ current: [Ticker]) async throws
    func load() async throws -> [Ticker]
}

class TickerPlistRepository: TickerListRepository {
    
    private var saved: [Ticker]?
    private let filename: String
    
    private var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(component: "\(filename).plist")
    }
    
    init(filename: String = "my_tickers") {
        self.filename = filename
    }
    
    func save(_ current: [Ticker]) throws {
        if let saved, saved == current { // 지금 저장 되어 있는 것과 같은지 확인
            return
        }
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try encoder.encode(current)
        try data.write(to: url, options: [.atomic])
        self.saved = current
    }
    
    
    func load() throws -> [Ticker] {
        let data = try Data(contentsOf: url)
        let current = try PropertyListDecoder().decode([Ticker].self, from: data)
        self.saved = current
        return current
    }
    
}

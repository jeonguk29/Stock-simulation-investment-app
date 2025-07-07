//
//  TradeUpApp.swift
//  TradeUp
//
//  Created by 정정욱 on 6/30/25.
//

import SwiftUI
import StocksAPI

@main
struct TradeUpApp: App {
    
    let stocksAPI = StocksAPI()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            let quotes = try await stocksAPI.quoteService.getQuotes(symbols: ["AAPL"])
                            print(quotes)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
        }
    }
}

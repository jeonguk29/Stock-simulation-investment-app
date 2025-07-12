//
//  SearchViewModel.swift
//  TradeUp
//
//  Created by MAC on 7/12/25.
//

import SwiftUI
import Combine
import StocksAPI

@MainActor
class SearchViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var phase: FetchPhase<[Ticker]> = .initial
    
    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var tickers: [Ticker] { phase.value ?? [] }
    var error: Error? { phase.error }
    var isSearching: Bool { !trimmedQuery.isEmpty }
    
    var emptyListText: String {
        "Symbols not found for\n\"\(query)\""
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let stocksAPI: StocksAPI
    
    init(query: String = "", stocksAPI: StocksAPI = StocksAPI()) {
        self.query = query
        self.stocksAPI = stocksAPI
    }
}

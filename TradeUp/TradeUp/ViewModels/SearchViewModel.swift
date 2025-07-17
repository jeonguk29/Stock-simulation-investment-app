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
    private let stocksAPI: StockRepository // 프로토콜화
    
    init(query: String = "", stocksAPI: StockRepository = StocksAPI()) {
        self.query = query
        self.stocksAPI = stocksAPI
        startObserving()
     }
     
     private func startObserving() {
         $query // 사용자 입역 쿼리를 구독해서 변경이 생기는것을 관찰
             .debounce(for: 0.25, scheduler: DispatchQueue.main)
             .sink { _ in
                 Task { [weak self] in await self?.searchTickers() }
             }
             .store(in: &cancellables)
         
         $query
             .filter { $0.isEmpty }
             .sink { [weak self] _ in self?.phase = .initial }
             .store(in: &cancellables)
     }
    
    func searchTickers() async {
        let searchQuery = trimmedQuery
        guard !searchQuery.isEmpty else { return }
        phase = .fetching
        
        do {
            let tickers = try await stocksAPI.searchTickers(query: searchQuery, isEquityTypeOnly: true)
            if searchQuery != trimmedQuery { return }
            if tickers.isEmpty {
                phase = .empty
            } else {
                phase = .success(tickers)
            }
        } catch {
            if searchQuery != trimmedQuery { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}

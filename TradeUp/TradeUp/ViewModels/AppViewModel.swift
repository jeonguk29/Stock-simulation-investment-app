//
//  AppViewModel.swift
//  TradeUp
//
//  Created by 정정욱 on 7/7/25.
//

import Foundation
import SwiftUI
import StocksAPI

@MainActor
class AppViewModel: ObservableObject {
    
    @Published var tickers: [Ticker] = [] {
        didSet { saveTickers() } // 값에 변경이 생기면 로칼에 저장
    }
    var titleText = "TradeUp"
    @Published var subtitleText: String
    var emptyTickersText = "Search & add symbol to see stock quotes"
    var attributionText = "Powered by Yahoo! finance API"
    
    private let subtitleDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        df.dateFormat = "M월 d일 (E)" // 예: 7월 12일 (금)
        return df
    }()
    
    let tickerListRepository: TickerListRepository
    
    init(repository: TickerListRepository = TickerPlistRepository()) {
        self.tickerListRepository = repository
        self.subtitleText = subtitleDateFormatter.string(from: Date())
        loadTickers()
    }
    
    private func loadTickers() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                self.tickers = try await tickerListRepository.load()
            } catch {
                print(error.localizedDescription)
                self.tickers = []
            }
        }
    }
    
    private func saveTickers() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.tickerListRepository.save(self.tickers)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isAddedToMyTickers(ticker: Ticker) -> Bool {
        tickers.first { $0.symbol == ticker.symbol } != nil
    }
    
    func toggleTicker(_ ticker: Ticker) {
        if isAddedToMyTickers(ticker: ticker) {
            removeFromMyTickers(ticker: ticker)
        } else {
            addToMyTickers(ticker: ticker)
        }
    }
    
    private func addToMyTickers(ticker: Ticker) {
        tickers.append(ticker)
    }
    
    private func removeFromMyTickers(ticker: Ticker) {
        guard let index = tickers.firstIndex(where: { $0.symbol == ticker.symbol }) else { return }
        tickers.remove(at: index)
    }
    
    func removeTickers(atOffsets offsets: IndexSet) {
        tickers.remove(atOffsets: offsets)
    }
    
    func openYahooFinance() {
        let url = URL(string: "https://finance.yahoo.com")!
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

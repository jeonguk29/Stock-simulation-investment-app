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
    
    @Published var tickers: [Ticker] = []
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
    
    init() {
        self.subtitleText = subtitleDateFormatter.string(from: Date())
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

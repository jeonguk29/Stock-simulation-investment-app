//
//  ChartViewModel.swift
//  TradeUp
//
//  Created by jeonguk29 on 7/31/25.
//

import Foundation
import SwiftUI
import StocksAPI

@MainActor
class ChartViewModel: ObservableObject {
    
    @Published var fetchPhase = FetchPhase<ChartViewData>.initial
    var chart: ChartViewData? { fetchPhase.value }
    
    let ticker: Ticker
    let apiService: StockRepository
    
    @AppStorage("selectedRange") private var _range = ChartRange.oneDay.rawValue 
    
    @Published var selectedRange = ChartRange.oneDay {
        didSet {
            _range = selectedRange.rawValue
        }
    }
    
    init(ticker: Ticker, apiService: StockRepository = StocksAPI()) {
        self.ticker = ticker
        self.apiService = apiService
        self.selectedRange = ChartRange(rawValue: _range) ?? .oneDay
    }
    
    func fetchData() async {
        do {
            fetchPhase = .fetching
            let rangeType = self.selectedRange
            let chartData = try await apiService.fetchChartData(tickerSymbol: ticker.symbol, range: rangeType)
            
            guard rangeType == self.selectedRange else { return } // 진행 되는 동안 변경 되지 않았다면
            if let chartData {
                fetchPhase = .success(transformChartViewData(chartData))
            } else {
                fetchPhase = .empty
            }
        } catch {
            fetchPhase = .failure(error)
        }
    }
    
    func transformChartViewData(_ data: ChartData) -> ChartViewData {
        let items = data.indicators.map{ ChartViewItem(timestamp: $0.timestamp, value: $0.close) }
        return ChartViewData(items: items)
    }
}

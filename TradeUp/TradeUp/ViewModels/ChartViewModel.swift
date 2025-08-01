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
        let yAxisChartData = yAxisChartData(data)
        return ChartViewData(
            yAxisData: yAxisChartData,
            items: items,
            lineColor: getLineColor(
                data: data
            ),
            previousCloseRuleMarkValue: previousCloseRuleMarkValue(data: data, yAxisData: yAxisChartData)
        )
    }
    
    // MARK: - 금일 주가 상승, 하락에 따른 차트 라인 컬러 변경
    func getLineColor(data: ChartData) -> Color {
        if let last = data.indicators.last?.close {
            // 현재 거래일의 종가가 직전 종가보다 크면 그린 그렇지 않으면 레드 색상
            if selectedRange == .oneDay, let prevClose = data.metadata.previousClose {
                return last >= prevClose ? .green : .red
            } else if let first = data.indicators.first?.close {
                return last >= first ? .green : .red
            }
        }
        return .blue
    }
    
    // MARK: - Y축(종가 표시를 위한)이 어디서부터 어디까지 보여줄지 결정하는 함수
    func yAxisChartData(_ data: ChartData) -> ChartAxisData {
        let closes = data.indicators.map { $0.close } // 종가 목록 가져오기

        var lowest = closes.min() ?? 0 // 종가 중 최솟값
        var highest = closes.max() ?? 0 // 종가 중 최댓값

        // 만약 전일 종가가 있고, 현재 차트 범위가 하루짜리라면
        if let prevClose = data.metadata.previousClose, selectedRange == .oneDay {
            // 전일 종가가 최솟값보다 더 낮으면 그것도 보여야 하니까 최솟값 갱신
            if prevClose < lowest {
                lowest = prevClose
            }
            // 전일 종가가 최댓값보다 더 높으면 최댓값 갱신
            else if prevClose > highest {
                highest = prevClose
            }
        }

        // 범위에 약간 여유 주기 (그래야 선이 딱 붙지 않음)
        return ChartAxisData(
            axisStart: lowest - 0.01,
            axisEnd: highest + 0.01
        )
    }
    
    // MARK: - 전일 종가(previousClose)가 Y축 범위 안에 있으면 그 값을 리턴해서 기준선(RuleMark)을 그리기 위한 함수
    func previousCloseRuleMarkValue(data: ChartData, yAxisData: ChartAxisData) -> Double? {
        guard let previousClose = data.metadata.previousClose, selectedRange == .oneDay else {
            return nil
        }
        return (yAxisData.axisStart <= previousClose && previousClose <= yAxisData.axisEnd) ? previousClose : nil
    }
}

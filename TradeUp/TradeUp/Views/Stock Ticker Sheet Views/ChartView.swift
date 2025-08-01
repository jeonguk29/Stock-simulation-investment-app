//
//  ChartView.swift
//  TradeUp
//
//  Created by jeonguk29 on 8/1/25.
//

import SwiftUI
import Charts
import StocksAPI

struct ChartView: View {
    
    let data: ChartViewData
    
    var body: some View {
        chart
            .chartYScale(
                domain: data.yAxisData.axisStart...data.yAxisData.axisEnd
            )
            .chartPlotStyle {
                chartPlotStyle(
                    $0
                )
            }
    }
    
    private var chart: some View {
        Chart{
            ForEach(data.items) {
                LineMark(
                    x: .value("Time", $0.timestamp),
                    y: .value("Price", $0.value)
                )
                .foregroundStyle(data.lineColor)
                
                AreaMark(
                    x: .value("Time", $0.timestamp),
                    yStart: .value("Min", data.yAxisData.axisStart),
                    yEnd: .value("Max", $0.value)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [
                        data.lineColor,
                        .clear
                    ]), startPoint: .top, endPoint: .bottom)
                ).opacity(0.3)
            }
            
            // MARK: - 전일 종가 기준선 표시
            /// 전일 종가가 존재하고, 그 값이 현재 차트 Y축 범위 안에 있다면, 해당 위치에 수평선을 그려서 사용자에게 기준선 표시
            if let previousClose = data.previousCloseRuleMarkValue {
                RuleMark(y: .value("Previous Close", previousClose))
                    .lineStyle(.init(lineWidth: 0.1, dash: [2]))
                    .foregroundStyle(.gray.opacity(0.3))
            }
        }
    }
    
    private func chartPlotStyle(_ plotContent: ChartPlotContent) -> some View {
        plotContent
            .frame(height: 200)
            .overlay {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5))
                    .mask(ZStack {
                        VStack {
                            Spacer()
                            Rectangle().frame(height: 1)
                        }
                        
                        HStack {
                            Spacer()
                            Rectangle().frame(width: 0.3)
                        }
                    })
            }
    }
}

struct ChartView_Previews: PreviewProvider {
    
    static let allRanges = ChartRange.allCases
    static let oneDayOngoing = ChartData.stub1DOngoing
    
    static var previews: some View {
        ForEach(allRanges) {
            ChartContainerView_Previews(vm: chartViewModel(range: $0, stub: $0.stubs), title: $0.title)
        }
        
        // 진행중인 차트
        ChartContainerView_Previews(vm: chartViewModel(range: .oneDay, stub: oneDayOngoing), title: "1D Ongoing")
    }
    
    static func chartViewModel(range: ChartRange, stub: ChartData) -> ChartViewModel {
        var mockStocksAPI = MockStocksAPI()
        mockStocksAPI.stubbedFetchChartDataCallback = { _ in stub }
        let chartVM = ChartViewModel(ticker: .stub, apiService: mockStocksAPI)
        chartVM.selectedRange = range
        return chartVM
    }
}

#if DEBUG
struct ChartContainerView_Previews: View {
    
    @StateObject var vm: ChartViewModel
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom)
            if let chartViewData = vm.chart {
                ChartView(data: chartViewData)
            }
        }
        .padding()
        .frame(maxHeight: 272)
        .previewLayout(.sizeThatFits)
        .previewDisplayName(title)
        .task { await vm.fetchData() }
    }
}
#endif

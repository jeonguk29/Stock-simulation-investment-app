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
    @ObservedObject var vm: ChartViewModel
    
    var body: some View {
        chart
            .chartXScale(domain: data.items.first!.timestamp...data.items.last!.timestamp) 
            .chartYScale(
                domain: data.yAxisData.axisStart...data.yAxisData.axisEnd
            )
            .chartPlotStyle {
                chartPlotStyle(
                    $0
                )
            }
            .chartOverlay { proxy in
                GeometryReader { gProxy in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { onChangeDrag(value: $0, chartProxy: proxy, geometryProxy: gProxy) }
                            .onEnded { _ in
                                vm.selectedX = nil
                            }
                        )
                }
            }
    }
    
    private var chart: some View {
        Chart{
            ForEach(data.items) {
                LineMark(
                    x: .value("Time", $0.timestamp),
                    y: .value("Price", $0.value)
                )
                .foregroundStyle(vm.foregroundMarkColor)
                
                AreaMark(
                    x: .value("Time", $0.timestamp),
                    yStart: .value("Min", data.yAxisData.axisStart),
                    yEnd: .value("Max", $0.value)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [
                        vm.foregroundMarkColor,
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
            
            // MARK: - 선택 X값 세로선 + 주석 텍스트(가격) 표시
            if let (selectedX, text) = vm.selectedXRuleMark {
                RuleMark(x: .value("Selected timestamp", selectedX))
                    .lineStyle(.init(lineWidth: 1))
                    .annotation {
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    .foregroundStyle(vm.foregroundMarkColor)
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
    
    // MARK: - 사용자가 드래그한 위치의 X값(= 시간, 날짜)을 계산해서 선택된 포인트로 저장하는 핵심 함수
    private func onChangeDrag(value: DragGesture.Value, chartProxy: ChartProxy, geometryProxy: GeometryProxy) {
        // 차트 범위 체크
        let xCurrent = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x
        if let timestamp: Date = chartProxy.value(atX: xCurrent),
           let startData = data.items.first?.timestamp,
           let lastData = data.items.last?.timestamp,
           timestamp >= startData && timestamp <= lastData {
            vm.selectedX = timestamp
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
                ChartView(data: chartViewData, vm: vm)
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

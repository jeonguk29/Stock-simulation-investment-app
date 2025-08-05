//
//  ChartViewData.swift
//  TradeUp
//
//  Created by jeonguk29 on 7/31/25.
//

import Foundation
import SwiftUI

struct ChartViewData: Identifiable {
    
    let id = UUID()
    let yAxisData: ChartAxisData
    let items: [ChartViewItem]
    let lineColor: Color
    let previousCloseRuleMarkValue: Double? // 전일 종가
}

struct ChartViewItem: Identifiable {
    
    let id = UUID()
    let timestamp: Date
    let value: Double
}

// MARK: - 차트의 Y축 범위를 관리하는 데이터
struct ChartAxisData {
    
    let axisStart: Double
    let axisEnd: Double
}

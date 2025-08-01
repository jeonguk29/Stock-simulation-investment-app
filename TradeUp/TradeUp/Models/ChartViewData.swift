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
    let items: [ChartViewItem]
    let lineColor: Color
}

struct ChartViewItem: Identifiable {
    
    let id = UUID()
    let timestamp: Date
    let value: Double
}

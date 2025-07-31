//
//  ChartRange+Extensions.swift
//  TradeUp
//
//  Created by MAC on 7/29/25.
//

import Foundation
import StocksAPI

// MARK: - 차트 날짜 범위
extension ChartRange: Identifiable {
    
    public var id: Self { self }
    
    var title: String {
        switch self {
        case .oneDay: return "1D"
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .threeMonth: return "3M"
        case .sixMonth: return "6M"
        case .oneYear: return "1Y"
        case .twoYear: return "2Y"
        case .fiveYear: return "5Y"
        case .tenYear: return "10Y"
        case .ytd: return "YTD"
        case .max: return "ALL"
        }
    }
    
}

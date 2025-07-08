//
//  TickerListRowData.swift
//  TradeUp
//
//  Created by 정정욱 on 7/7/25.
//

import Foundation

typealias PriceChange = (price: String, change: String)

struct TickerListRowData {
    
    enum RowType {
        case main
        case search(isSaved: Bool, onButtonTapped: () -> ())
    }
    
    let symbol: String
    let name: String?
    let price: PriceChange?
    let type: RowType
}

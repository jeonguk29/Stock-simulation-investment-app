//
//  Quote+Extensions.swift
//  TradeUp
//
//  Created by 정정욱 on 7/7/25.
//

import Foundation
import StocksAPI

extension Quote {
    
    var isTrading: Bool {
         guard let marketState, marketState == "REGULAR" else {
             return false
         }
         return true
     }
    
    var regularPriceText: String? {
        Utils.format(value: regularMarketPrice)
    }
    
    var regularDiffText: String? {
        guard let text = Utils.format(value: regularMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
    var postPriceText: String? {
        Utils.format(value: postMarketPrice)
    }
    
    var postPriceDiffText: String? {
        guard let text = Utils.format(value: postMarketPriceChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
}

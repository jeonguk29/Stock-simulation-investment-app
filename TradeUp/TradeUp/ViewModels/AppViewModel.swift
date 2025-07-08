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
    
}

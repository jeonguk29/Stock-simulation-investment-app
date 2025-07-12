//
//  TradeUpApp.swift
//  TradeUp
//
//  Created by 정정욱 on 6/30/25.
//

import SwiftUI
import StocksAPI

@main
struct TradeUpApp: App {
    
    @StateObject var appVM = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainListView()
            }
            .environmentObject(appVM)
        }
    }
}

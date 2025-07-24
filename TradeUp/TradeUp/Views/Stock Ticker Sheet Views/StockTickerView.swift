//
//  StockTickerView.swift
//  TradeUp
//
//  Created by MAC on 7/24/25.
//

import SwiftUI
import StocksAPI

struct StockTickerView: View {
    
    @StateObject var quoteVM: TickerQuoteViewModel
    @State var selectedRange = ChartRange.oneDay
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
         
        }
    }
}


struct StockTickerView_Previews: PreviewProvider {
    
    static var tradingStubsQuoteVM: TickerQuoteViewModel = {
        var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            [Quote.stub(isTrading: true)]
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    static var closedStubsQuoteVM: TickerQuoteViewModel = {
        var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            [Quote.stub(isTrading: false)]
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    
    static var loadingStubsQuoteVM: TickerQuoteViewModel = {
        var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            await withCheckedContinuation { _ in
                
            }
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    
    static var errorStubsQuoteVM: TickerQuoteViewModel = {
        var mockAPI = MockStocksAPI()
        mockAPI.stubbedFetchQuotesCallback = {
            throw NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error has been occured"])
        }
        return TickerQuoteViewModel(ticker: .stub, stocksAPI: mockAPI)
    }()
    
    static var previews: some View {
        Group {
            StockTickerView(quoteVM: tradingStubsQuoteVM)
                .previewDisplayName("Trading")
                .frame(height: 700)
            
            StockTickerView(quoteVM: closedStubsQuoteVM)
                .previewDisplayName("Closed")
                .frame(height: 700)
            
            StockTickerView(quoteVM: loadingStubsQuoteVM)
                .previewDisplayName("Loading Quote")
                .frame(height: 700)
            
            StockTickerView(quoteVM: errorStubsQuoteVM)
                .previewDisplayName("Error Quote")
                .frame(height: 700)
            
        }.previewLayout(.sizeThatFits)
    }
}

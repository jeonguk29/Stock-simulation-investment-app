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
            headerView.padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
                .padding(.horizontal)
            scrollView
        }
        .padding(.top)
        .background(Color(uiColor: .systemBackground))
        .task { await quoteVM.fetchQuote() }
    }
    
    // 심볼, 종목 이름, 닫기 버튼
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(quoteVM.ticker.symbol).font(.title.bold())
            if let shortName = quoteVM.ticker.shortname {
                Text(shortName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            Spacer()
            closeButton
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Circle()
                .frame(width: 36, height: 36)
                .foregroundColor(.gray.opacity(0.1))
                .overlay {
                    Image(systemName: "xmark")
                        .font(.system(size: 18).bold())
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
        }
        .buttonStyle(.plain)
    }
    
    private var scrollView: some View {
        ScrollView {
            priceDiffRowView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal)
            
            Divider()
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, alignment: .leading) // 이게 alignment: .leading 어떤 의미지?
    }
    
    // 가격 및 등락 정보 표시 (장중 거래 중, 장 종료 후)
    private var priceDiffRowView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let quote = quoteVM.quote {
                HStack {
                    if quote.isTrading,
                       let price = quote.regularPriceText,
                       let diff = quote.regularDiffText {
                        priceDiffStackView(price: price, diff: diff, caption: nil) // 거래중일때는 nil
                    } else {
                        if let atCloseText = quote.regularPriceText,
                           let atCloseDiffText = quote.regularDiffText {
                            priceDiffStackView(price: atCloseText, diff: atCloseDiffText, caption: "At Close")
                        }
                        
                        if let afterHourText = quote.postPriceText,
                           let afterHourDiffText = quote.postPriceDiffText {
                            priceDiffStackView(price: afterHourText, diff: afterHourDiffText, caption: "After Hours")
                        }
                    }
                    
                    Spacer()
                }
            }
            exchangeCurrencyView // 통화, 거래서 표현
        }
    }
    
    // 가격/변동 정보 출력 포맷
    private func priceDiffStackView(price: String, diff: String, caption: String?) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline, spacing: 16) {
                Text(price).font(.headline.bold())
                Text(diff).font(.subheadline.weight(.semibold))
                    .foregroundColor(diff.hasPrefix("-") ? .red : .green)
            }
            
            if let caption {
                Text(caption)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    // 거래소 및 통화 정보
    private var exchangeCurrencyView: some View {
        HStack(spacing: 4) {
            if let exchange = quoteVM.ticker.exchDisp {
                Text(exchange)
            }
            
            if let currency = quoteVM.quote?.currency {
                Text("·")
                Text(currency)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(Color(uiColor: .secondaryLabel))
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

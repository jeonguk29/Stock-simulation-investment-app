//
//  SearchView.swift
//  TradeUp
//
//  Created by MAC on 7/12/25.
//

import SwiftUI
import StocksAPI

@MainActor
struct SearchView: View {
    
    @EnvironmentObject var appVM: AppViewModel
    @StateObject var quotesVM = QuotesViewModel()
    @ObservedObject var searchVM: SearchViewModel
    
    var body: some View {
        List(searchVM.tickers) { ticker in
            TickerListRowView(
                data: .init(
                    symbol: ticker.symbol,
                    name: ticker.shortname,
                    price: quotesVM.priceForTicker(ticker),
                    type: .search(
                        isSaved: appVM.isAddedToMyTickers(ticker: ticker),
                        onButtonTapped: {
                            Task { @MainActor in
                                appVM.toggleTicker(ticker)
                            }
                        }
                    )
                )
            )
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .listStyle(.plain)
        .overlay { listSearchOverlay }
    }
    
    @ViewBuilder
    private var listSearchOverlay: some View {
        switch searchVM.phase {
        case .failure(let error):
            ErrorStateView(error: error.localizedDescription){}
        case .empty:
            EmptyStateView(text: searchVM.emptyListText)
        case .fetching:
            LoadingStateView()
        default: EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    
    @StateObject static var stubbedSearchVM: SearchViewModel = {
        var vm = SearchViewModel()
        vm.phase = .success(Ticker.stubs)
        return vm
    }()
    
    @StateObject static var emptySearchVM: SearchViewModel = {
        var vm = SearchViewModel()
        vm.query = "Theranos"
        vm.phase = .empty
        return vm
    }()
    
    @StateObject static var loadingSearchVM: SearchViewModel = {
        var vm = SearchViewModel()
        vm.phase = .fetching
        return vm
    }()
    
    @StateObject static var errorSearchVM: SearchViewModel = {
        var vm = SearchViewModel()
        vm.phase = .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "An Error has been occurred"]))
        return vm
    }()
    
    @StateObject static var appVM: AppViewModel = {
        let vm = AppViewModel()
        vm.tickers = Array(Ticker.stubs.prefix(upTo:2)) //0,1 만 가져와서 체크되도록
        return vm
    }()
    
    static var quotesVM: QuotesViewModel = {
        var vm = QuotesViewModel()
        vm.quotesDict = Quote.stubsDict
        return vm
    }()
    
    static var previews: some View {
        Group {
            NavigationStack {
                SearchView(quotesVM: quotesVM, searchVM: stubbedSearchVM)
            }
            .searchable(text: $stubbedSearchVM.query) // 이거 뭐지
            .previewDisplayName("Results")
            
            NavigationStack {
                SearchView(quotesVM: quotesVM, searchVM: emptySearchVM)
            }
            .searchable(text: $emptySearchVM.query)
            .previewDisplayName("Empty Results")
            
            NavigationStack {
                SearchView(quotesVM: quotesVM, searchVM: loadingSearchVM)
            }
            .searchable(text: $loadingSearchVM.query)
            .previewDisplayName("Loading State")
            
            NavigationStack {
                SearchView(quotesVM: quotesVM, searchVM: errorSearchVM)
            }
            .searchable(text: $errorSearchVM.query)
            .previewDisplayName("Error State")
            
            
        }.environmentObject(appVM)
    }
}

//
//  DateRangePickerView.swift
//  TradeUp
//
//  Created by MAC on 7/29/25.
//

import SwiftUI
import StocksAPI

struct DateRangePickerView: View {
    
    let rangeTypes = ChartRange.allCases
    @Binding var selectedRange: ChartRange
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(self.rangeTypes) { dateRange in
                    Button {
                        self.selectedRange = dateRange
                    } label: {
                        Text(dateRange.title)
                            .font(.callout.bold())
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .background {
                        if dateRange == selectedRange {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.4))
                        }
                    }
                }
                
            }.padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

struct DateRangePickerView_Previews: PreviewProvider {
    
    @State static var dateRange = ChartRange.oneDay
    
    static var previews: some View {
        DateRangePickerView(selectedRange: $dateRange)
            .padding(.vertical)
            .previewLayout(.sizeThatFits)
    }
}

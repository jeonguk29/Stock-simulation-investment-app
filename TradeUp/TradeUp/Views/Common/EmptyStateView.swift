//
//  EmptyStateView.swift
//  TradeUp
//
//  Created by 정정욱 on 7/7/25.
//

import SwiftUI

struct EmptyStateView: View {
    
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Spacer()
        }
        .padding(64)
        .lineLimit(3)
        .multilineTextAlignment(.center)
        
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(text: "No data available")
    }
}

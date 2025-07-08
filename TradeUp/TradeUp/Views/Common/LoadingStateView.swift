//
//  LoadingStateView.swift
//  TradeUp
//
//  Created by 정정욱 on 7/7/25.
//

import SwiftUI

struct LoadingStateView: View {
    
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView()
    }
}

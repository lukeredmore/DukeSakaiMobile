//
//  AnnoucementDetailView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import SwiftUI
import WebKit

struct AnnoucementDetailView: View {
    @State var text: String
    
    var body: some View {
        HTMLWebView(text: $text)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
    }
}


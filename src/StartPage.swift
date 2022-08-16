//
//  StartPage.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/16/22.
//

import SwiftUI

struct StartPage: View {
    @State private var showingLoginSheet = false
    let completion: ((accessToken: String, sessionToken: String)) -> Void
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Button {
                    showingLoginSheet = true
                } label: {
                    Text("Login")
                        .frame(width: geo.size.width > 300.0 ? 250 : geo.size.width*0.6,
                               height: 70.0)
                        .foregroundColor(.white)
                        .font(.custom("OpenSans",
                                      fixedSize: 24.0)
                            .weight(UIAccessibility.isBoldTextEnabled ? .bold : .semibold))
                        .background(Color("DukeNavy"))
                        .cornerRadius(16.0)
                }.offset(x: 0, y: -50)
            }.frame(width: geo.size.width, height: geo.size.height)
        }.sheet(isPresented: $showingLoginSheet) {
            AuthWebView { result in
                showingLoginSheet = false
                if let result = result {
                    completion(result)
                } else {
                    //TODO: handle auth flow canceled
                }
            }
            .interactiveDismissDisabled()
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
        }
    }
}

struct StartPage_Previews: PreviewProvider {
    static var previews: some View {
        StartPage() { _ in }
    }
}

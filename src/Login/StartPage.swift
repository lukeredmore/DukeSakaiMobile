//
//  StartPage.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/16/22.
//

import SwiftUI

struct StartPage: View {
    @State private var showingLoginSheet = false
    @State private var showingInfoSheet = false
    let completion: ((accessToken: String, sessionToken: String)) -> Void
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                    }
                }
                Spacer()
                Button {
                    showingLoginSheet = true
                } label: {
                    Text("Login with NetID")
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
        }.sheet(isPresented: $showingInfoSheet) {
            if #available(iOS 16.0, *) {
                LogViewer()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                showingInfoSheet = false
                            }
                        }
                    }
                    .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
            } else {
                LogViewer()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                showingInfoSheet = false
                            }
                        }
                    }
            }
            
        }
    }
}

struct StartPage_Previews: PreviewProvider {
    static var previews: some View {
        StartPage() { _ in }
    }
}

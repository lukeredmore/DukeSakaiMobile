//
//  ShareNavigationView.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/24/22.
//

import SwiftUI

struct ShareNavigationView: View {
    @EnvironmentObject private var env: ImportEnvironment
    @State private var navBarHeight: CGFloat = 0.0
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    @ViewBuilder
    var content: some View {
        AssignmentLoaderView()
    }
    
    @ViewBuilder
    var header: some View {
        if let files = env.files {
            FilePreview(files: files)
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    Spacer().frame(height: env.headerHeight)
                    
                    content
                        .navigationTitle("Attach Work")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    env.cancel()
                                } label: {
                                    Text("Cancel").foregroundColor(.white)
                                }
                            }
                        }
                        .onChange(of: geo.safeAreaInsets.top) { newValue in
                            navBarHeight = newValue
                        }
                        .alert(alertMessage, isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { showingAlert = false }
                        }
                }
            }
        }
        .onAppear {
            env.showAlert = { msg in
                alertMessage = msg
                showingAlert = true
            }
            
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "DukeNavy")
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = textAttributes
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance
        }
        .overlay(alignment: .top) {
            VStack {
                Spacer()
                    .frame(height: navBarHeight)
                header.background(GeometryReader { geo2 in
                    Color.clear.onChange(of: geo2.size.height) { newValue in
                        print("Header is \(newValue)")
                        env.headerHeight = newValue
                    }
                    .onAppear {
                        print("Header is \(geo2.size.height) on appear")
                        env.headerHeight = geo2.size.height
                    }
                })
            }
        }
    }
}


//struct ShareNavigationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShareNavigationView()
//    }
//}

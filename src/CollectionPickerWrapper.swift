//
//  CollectionPickerWrapper.swift
//  DukeSakai
//
//  Created by Luke Redmore on 8/15/22.
//

import SwiftUI

struct LogoutButton: View {
    @EnvironmentObject var env : SakaiEnvironment
    
    @State private var showingOptions = false
    
    var body: some View {
        Button("Sign Out") {
            showingOptions = true
        }
        .foregroundColor(.white)
        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showingOptions, titleVisibility: .visible) {
            SwiftUI.Button("Sign out", role: .destructive, action: env.logout)
            
        }
    }
}

struct CollectionPickerWrapper<T: View>: View {
    @EnvironmentObject var env : SakaiEnvironment
    var content: () -> T
    
    var toolbarButton: some View {
        Button {
            env.collectionPickerShown.toggle()
        } label: {
            Text(env.selectedCollection.collectionName == "Favorites" ? "Favorite Courses" : env.selectedCollection.collectionName)
                .font(.headline)
                .fixedSize(horizontal: true, vertical: false)
                .offset(x: 4.0, y: 0.0)
                .foregroundColor(.white)
            
            Image(systemName: "chevron.down")
                .scaleEffect(0.9)
                .offset(x: -3.0, y: 0.0)
                .rotationEffect(.degrees(env.collectionPickerShown ? -180 : 0), anchor: UnitPoint(x: 0.4, y: 0.5))
                .animation(.spring(), value: env.collectionPickerShown)
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        NavigationView {
            content()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .principal) { toolbarButton } }
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { LogoutButton() }}
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "DukeNavy")
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = textAttributes
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance
        }
    }
}

//
//  CollectionsLoader.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI

struct CollectionsLoader: View {
    @StateObject var env = SakaiEnvironment()
    let courseIds: [String]
    let logout: () -> Void
    
    var body: some View {
        if env.termCollections.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .onAppear { Task {
                    await env.createInitialEnv(courseIds: courseIds, logout: logout)
                    print("Created Environment, showing home screen")
                }}
        } else {
            HomeTabView()
                .popupMenu(isPresented: $env.collectionPickerShown) {
                    CollectionPickerView() { env.collectionPickerShown = false }
                }
                .environmentObject(env)
        }
    }
}

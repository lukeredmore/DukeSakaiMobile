//
//  RootNavigationView.swift
//  Shared
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct RootNavigationView: View {
    @State private var isAuthenticated = false
    @State private var courses : [Course] = []
    
    var body: some View {
        NavigationView {
            VStack {
                LoginView(courses: $courses)
                    .navigationBarHidden(true)
                    .navigationTitle("")
                NavigationLink("", destination: HomeView(courses: $courses), isActive: $isAuthenticated)
               
            }
        }.onChange(of: courses) { new in
            print("got new")
            print(new)
            if !new.isEmpty {
                isAuthenticated = true
            }
        }
        
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}

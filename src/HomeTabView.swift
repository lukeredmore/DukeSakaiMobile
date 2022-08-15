//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HomeTabView: View {
    @State private var selection = 3
    
    var body: some View {
        TabView(selection: $selection) {
            Text("This is your gradebook")
                .tabItem {
                    Image(systemName: "text.book.closed")
                    Text("Grades")
                }
                .tag(1)
            
            AsyncContentView(loader: AssignmentsRetriever.getAssignments,
                             content: AssignmentsNavigationView.build)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Assignments")
                }
                .tag(2)
            
            AsyncContentView(loader: AnnouncementsRetriever.getAnnouncements,
                             content: AnnouncementsNavigationView.build)
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Alerts")
                }
                .tag(3)
            
            ResourceOverviewView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Resources")
                }
                .tag(4)
        }
    }
}

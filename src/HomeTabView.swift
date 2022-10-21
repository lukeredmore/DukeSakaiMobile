//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var env : SakaiEnvironment
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        
        tabBarAppearance.backgroundColor = UIColor(named: "DukeNavy")
        
        tabBarItemAppearance.selected.iconColor = .white
        tabBarItemAppearance.normal.iconColor = UIColor(named: "LogoGray")

        tabBarItemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: Font.tabBarItem]
        tabBarItemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "LogoGray")!,
            .font: Font.tabBarItem]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView(selection: $env.selectedTab) {
            GradeWebViewContainer()
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
            LogViewer()
//            BARStatusView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Info")
                }
                .tag(5)
        }
    }
}

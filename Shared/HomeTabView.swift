//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var showMenu: Bool
    @State private var selection = 3
    var course: Course
    
    var body: some View {
        TabView(selection: $selection) {
            Text("This is your gradebook for \(course.name)")
                .tabItem {
                    Image(systemName: "text.book.closed")
                    Text("Grades")
                }
                .tag(1)
            Text("These are assignments for \(course.name)")
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Assignments")
                }
                .tag(2)
            Text("These are announcements for \(course.name)")
                .tabItem {
                    Image(systemName: "bell")
                    Text("Announcements")
                }
                .tag(3)
            ResourcesNavigationView(siteId: course.siteId)
                .tabItem {
                    Image(systemName: "folder")
                    Text("Resources")
                }
                .tag(4)
            Text("More for \(course.name)")
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("More")
                }
                .tag(5)
        }
        
        
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView(showMenu: .constant(true), course: Course(name: "Course 1", siteId: "id", term: "da", instructor: "Ad", lastModified: 123))
    }
}

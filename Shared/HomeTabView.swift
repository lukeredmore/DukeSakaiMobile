//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var selectedCollection: CourseCollection
    
    private var courseNames: String {
        selectedCollection.courses.map { course in
            return course.name
        }.joined(separator: ", ")
    }
    
    @State private var selection = 3
    var body: some View {
        TabView(selection: $selection) {
            Text("This is your gradebook for \(courseNames)")
                .tabItem {
                    Image(systemName: "text.book.closed")
                    Text("Grades")
                }
                .tag(1)
            
            RemoteContentView(selectedCollection: $selectedCollection,
                              loader: AssignmentsRetriever.getAssignments,
                              builder: AssignmentsNavigationView.build)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Assignments")
                }
                .tag(2)
            
            RemoteContentView(selectedCollection: $selectedCollection,
                              loader: AnnouncementsRetriever.getAnnouncements) { AnnouncementsNavigationView.build($0, hasMultipleCourses: selectedCollection.courses.count > 1) }
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Alerts")
                }
                .tag(3)
            
            RemoteContentView(selectedCollection: $selectedCollection,
                              loader: ResourceRetriever.getResources,
                              builder: ResourcesNavigationView.build)
                .tabItem {
                    Image(systemName: "folder")
                    Text("Resources")
                }
                .tag(4)
        }
    }
}

//struct HomeTabView_Previews: PreviewProvider {
//    static var previews: some View {
//            HomeTabView(allCollections:
//                    .constant(PreviewUtils.allCollections))
//    }
//}

//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI
import AsyncView

//struct LastWrapper: View {
//    @ObservedObject var avm : AssignmentsViewModel
//
//
//
//    var body: some View {
//        RemoteContentView(source: avm) {
//            List($0, id: \.title) { item in
//                Text(item.title)
//            }
//        }.onChange(of: avm.state) { st in
//            print("new state \(st.str)")
//        }
//    }
//}

struct HomeTabView: View {
    @Binding var selectedCollection: CourseCollection
    
    @StateObject var annoucementsModel: AsyncModel<[Announcement]>
    @StateObject var assignmentsModel: AsyncModel<[Assignment]>
    @StateObject var resourcesModel: AsyncModel<[Resource]>
    
    init(selectedCollection: Binding<CourseCollection>) {
        self._selectedCollection = selectedCollection
        self._annoucementsModel = StateObject(wrappedValue: AsyncModel { try await AnnouncementsRetriever.getAnnouncements(for: selectedCollection.wrappedValue) })
        self._assignmentsModel = StateObject(wrappedValue: AsyncModel { try await AssignmentsRetriever.getAssignments(for: selectedCollection.wrappedValue) })
        self._resourcesModel = StateObject(wrappedValue: AsyncModel { try await ResourceRetriever.getResources(for: selectedCollection.wrappedValue) })
    }
    
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
            
            AsyncModelView(model: assignmentsModel, content: AssignmentsNavigationView.build)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Assignments")
                }
                .tag(2)
            
            AsyncModelView(model: annoucementsModel) { AnnouncementsNavigationView.build($0, hasMultipleCourses: selectedCollection.courses.count > 1) }
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Alerts")
                }
                .tag(3)
            
            AsyncModelView(model: resourcesModel, content: ResourcesNavigationView.build)
                .tabItem {
                    Image(systemName: "folder")
                    Text("Resources")
                }
                .tag(4)
        }
        .onChange(of: selectedCollection) { selco in
            print("Selected collection changed, reloading models")
            Task {
                await assignmentsModel.load()
                await annoucementsModel.load()
                await resourcesModel.load()
            }
            
        }
    }
}

//struct HomeTabView_Previews: PreviewProvider {
//    static var previews: some View {
//            HomeTabView(allCollections:
//                    .constant(PreviewUtils.allCollections))
//    }
//}

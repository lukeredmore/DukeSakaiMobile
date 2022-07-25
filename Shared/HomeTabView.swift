//
//  HomeTabView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var allCollections: [CourseCollection]
    
    init(allCollections: Binding<[CourseCollection]>) {
        _allCollections = allCollections
        
        selectedCollection = CollectionPickerView.prelimFavsOrDefaultSelectedCourses(allCollections: allCollections.wrappedValue)
    }
    
    @State private var selection = 3
    @State private var selectedCollection: CourseCollection
    @State private var collectionPickerShown = false
    
    private var courseNames: String {
        selectedCollection.courses.map { course in
            return course.name
        }.joined(separator: ", ") ?? "nil"
    }
    
    var toolbarButton: some View {
        Button {
            collectionPickerShown.toggle()
        } label: {
            Text(selectedCollection.collectionName == "Favorites" ? "Favorite Courses" : selectedCollection.collectionName)
                .font(.headline)
                .fixedSize(horizontal: true, vertical: false)
                .offset(x: 4.0, y: 0.0)
                .foregroundColor(Color.primary)
            
            Image(systemName: "chevron.down")
                .scaleEffect(0.9)
                .offset(x: -3.0, y: 0.0)
                .rotationEffect(.degrees(collectionPickerShown ? -180 : 0), anchor: UnitPoint(x: 0.4, y: 0.5))
                .animation(.spring(), value: collectionPickerShown)
                .foregroundColor(Color.primary)
        }
        
        
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                Text("This is your gradebook for \(courseNames)")
                    .tabItem {
                        Image(systemName: "text.book.closed")
                        Text("Grades")
                    }
                    .tag(1)
                Text("These are assignments for \(courseNames)")
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Assignments")
                    }
                    .tag(2)
                RemoteContentView(source: AnnoucementsViewModel(selectedCollection)) {
                    AnnouncementsNavigationView(courseNameFollowsAuthorName: selectedCollection.courses.count > 1,
                                                annoucements: $0)
                }
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Alerts")
                }
                .tag(3)
                ResourcesNavigationView(collection: selectedCollection)
                    .tabItem {
                        Image(systemName: "folder")
                        Text("Resources")
                    }
                    .tag(4)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { toolbarButton } }
        }.popupMenu(isPresented: $collectionPickerShown) {
            CollectionPickerView(collections: allCollections, selectedCollection: $selectedCollection)
        }.onChange(of: selectedCollection) { _ in
            collectionPickerShown = false
        }
    }
}

//struct HomeTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView  {
//            HomeTabView(allCollections:
//                    .constant(PreviewUtils.allCollections))
//        }
//    }
//}

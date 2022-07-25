//
//  CollectionCoordinatorView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI

struct CollectionCoordinatorView: View {
    @State private var selectedCollection: CourseCollection // never nil,  Tab can read
    @State private var termCollections: [CourseCollection] // never nil, Picker can read, Tab no access
    @State private var favoritesCollection : CourseCollection // Picker can read/mutate, Tab no access
    
    @State private var collectionPickerShown = false
    
    @Binding var allCourses: [Course]
    init(_ all: Binding<[Course]>) {
        _allCourses = all
        print("creating term collections and favorites in init")
        let term = Course.organizeByTerm(courses: courses)
        termCollections = term
        
        let favorites = UserDefaults.standard.array(forKey: "favorite-course-ids") as? [String] ?? []
        let favoriteCourses = all.wrappedValue.filter { course in
            favorites.contains(course.siteId)
        }
        let fav = CourseCollection(collectionName: "Favorites", courses: favoriteCourses)
        favoritesCollection = fav
        
        selectedCollection = favoriteCourses.isEmpty ? term[0] : fav
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
    
    func onCollectionSelected(_ newCollection: CourseCollection) {
        print("A collection was selected")
        selectedCollection = newCollection
        collectionPickerShown = false
    }
    
    var body: some View {
        NavigationView {
            HomeTabView(selectedCollection: $selectedCollection)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .principal) { toolbarButton } }
        }
        .popupMenu(isPresented: $collectionPickerShown) {
            CollectionPickerView(favoritesCollection: $favoritesCollection,
                                 termCollections: $termCollections,
                                 collectionSelected: onCollectionSelected)
            .onChange(of: favoritesCollection) { newFavs in
                print("got new favorites, saving to UserDefaults")
                if selectedCollection.collectionName == "Favorites" {
                    print("favorites selected, making them this new thing")
                    print(newFavs.courses.count)
                    selectedCollection = newFavs
                }
                let favCourses = newFavs.courses.map { $0.siteId }
                UserDefaults.standard.set(favCourses, forKey: "favorite-course-ids")
            }
        }
    }
}

struct CollectionCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionCoordinatorView(.constant(PreviewUtils.courseList))
    }
}

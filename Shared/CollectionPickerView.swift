//
//  CollectionPickerView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct CollectionPickerView: View {
    @State private var favorites: [String]
    @Binding var selectedCollection: CourseCollection
    
    private let allCoursesCollection: CourseCollection
    private var favoritesCollection: CourseCollection {
        let favoriteCourses = allCoursesCollection.courses.filter { course in
            favorites.contains(course.siteId)
        }
        return CourseCollection(collectionName: "Favorites", courses: favoriteCourses)
    }
    private let remainingCollections: [CourseCollection]
    
    static func prelimFavsOrDefaultSelectedCourses(allCollections: [CourseCollection]) -> CourseCollection {
        
        let allCourses = allCollections.first { col in col.collectionName == "All Courses" }
        let favorites = UserDefaults.standard.array(forKey: "favorite-course-ids") as? [String] ?? []
        if !favorites.isEmpty {
            let favoriteCourses = allCourses!.courses.filter { course in
                favorites.contains(course.siteId)
            }
            return CourseCollection(collectionName: "Favorites", courses: favoriteCourses)
        } else {
            let termCoursesCollection = allCollections.first { col in col.collectionName != "All Courses" }
            return termCoursesCollection!
        }
        
    }
    
    init(collections: [CourseCollection], selectedCollection: Binding<CourseCollection>) {
        _selectedCollection = selectedCollection
        
        var collec = collections
        let allCoursesIndex = collec.firstIndex { col in col.collectionName == "All Courses" }
        self.allCoursesCollection = collec.remove(at: allCoursesIndex!)
        
        self.remainingCollections = collec
        favorites = UserDefaults.standard.array(forKey: "favorite-course-ids") as? [String] ?? []
        
        
//        if self.selectedCollection.collectionName == "" {
//                    let favs = favoritesCollection
//                    if !favs.courses.isEmpty {
//                        self.selectedCollection = favs
//                    } else {
//                        self.selectedCollection = remainingCollections[0]
//                    }
//                }
        
//        if self.selectedCollection.collectionName == "" {
//            let favs = favoritesCollection
//            if !favs.courses.isEmpty {
//                self.selectedCollection = favs
//            } else {
//                self.selectedCollection = remainingCollections[0]
//            }
//        }
    }
    
    @ViewBuilder
    func HeaderRow(collection: CourseCollection) -> some View {
           
            HStack {
                Spacer()
                Text(collection.collectionName)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .scaleEffect(0.6)
                    .offset(x: -2.0)
                    .foregroundColor(Color(UIColor.systemGray2))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(7)
            .background(Color(UIColor.systemGray5))
            
            
            
                        
                            
            //                        .border(width: 0.7, edges: [.bottom], color: .gray)
        
        
    }
    
    @ViewBuilder
    func CourseRow(singleCourseCollection: CourseCollection, favorite: Bool) -> some View {
        HStack {
            Button {
                if favorite {
                    print("removing \(singleCourseCollection.courses[0].siteId) from favorites")
                    favorites.removeAll { favId in favId == singleCourseCollection.courses[0].siteId }
                } else {
                    print("adding \(singleCourseCollection.courses[0].siteId) to favorites")
                    favorites.append(singleCourseCollection.courses[0].siteId)
                }
            } label: {
                Image(systemName: "star\(favorite ? ".fill" : "")")
                    .foregroundColor(favorite ? .yellow : .primary)
            }
            Text(singleCourseCollection.collectionName)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.systemGray2))
                .scaleEffect(0.6)
        }
        .padding(9)
//        .border(width: 0.7, edges: [.top], color: .gray)
        }
//    else {
//            EmptyView()
//        }
//    }
    
    
    @ViewBuilder
    func SelectableRow(_ collection: CourseCollection) -> some View {
        if !collection.courses.isEmpty {
        Button {
            selectedCollection = collection
        } label : {
            HeaderRow(collection: collection)
        }
        }
    }
    
    @ViewBuilder
    func SelectableRow(_ course: Course, showFavorites: Bool = false) -> some View {
        let favorite = favorites.contains(course.siteId)
        
        if !favorite || showFavorites {
            let singleCourseCollection = CourseCollection(collectionName: course.name,
                                                          courses: [course])
            Button {
                selectedCollection = singleCourseCollection
            } label : {
                CourseRow(singleCourseCollection: singleCourseCollection,
                          favorite: favorite)
            }
        }
    }
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
//                HeaderRow(collection: allCoursesCollection) This looks weird, how to show selectable?
                SelectableRow(favoritesCollection)
                ForEach(favoritesCollection.courses, id: \.siteId) { SelectableRow($0, showFavorites: true) }
                ForEach(remainingCollections, id: \.collectionName) { collection in
                    SelectableRow(collection)
                    ForEach(collection.courses, id: \.siteId) { SelectableRow($0) }
                }
            }
        }
        .onDisappear {
            UserDefaults.standard.set(favorites, forKey: "favorite-course-ids")
        }
    }
}

struct CollectionPickerView_Previews: PreviewProvider {
    static let cols = PreviewUtils.allCollections
    
    @ViewBuilder
    static var previews: some View {
        print(cols)
        return CollectionPickerView(collections: cols, selectedCollection: .constant(cols[0]))
    }
}

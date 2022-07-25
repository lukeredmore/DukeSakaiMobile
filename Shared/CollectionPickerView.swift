//
//  CollectionPickerView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct CollectionPickerView: View {
    @Binding var favoritesCollection: CourseCollection
    @Binding var termCollections: [CourseCollection]
    var collectionSelected: (_ newCollection: CourseCollection) -> Void
    
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
    }
    
    @ViewBuilder
    func CourseRow(singleCourseCollection: CourseCollection, favorite: Bool) -> some View {
        HStack {
            Button {
                if favorite {
                    print("removing \(singleCourseCollection.courses[0].siteId) from favorites")
                    let favs = favoritesCollection.courses.filter { fav in fav != singleCourseCollection.courses[0] }
                    favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favs)
                } else {
                    print("adding \(singleCourseCollection.courses[0].siteId) to favorites")
                    var favs = favoritesCollection.courses
                    favs.append(singleCourseCollection.courses[0])
                    favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favs)
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
    }
    
    
    @ViewBuilder
    func SelectableRow(_ collection: CourseCollection) -> some View {
        if !collection.courses.isEmpty {
            Button {
                collectionSelected(collection)
            } label : {
                HeaderRow(collection: collection)
            }
        }
    }
    
    @ViewBuilder
    func SelectableRow(_ course: Course, showFavorites: Bool = false) -> some View {
        let favorite = favoritesCollection.courses.contains(course)
        
        if !favorite || showFavorites {
            let singleCourseCollection = CourseCollection(collectionName: course.name,
                                                          courses: [course])
            Button {
                collectionSelected(singleCourseCollection)
            } label : {
                CourseRow(singleCourseCollection: singleCourseCollection,
                          favorite: favorite)
            }
        }
    }
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                SelectableRow(favoritesCollection)
                ForEach(favoritesCollection.courses, id: \.siteId) { SelectableRow($0, showFavorites: true) }
                ForEach(termCollections, id: \.collectionName) { collection in
                    SelectableRow(collection)
                    ForEach(collection.courses, id: \.siteId) { SelectableRow($0) }
                }
            }
        }
    }
}

//struct CollectionPickerView_Previews: PreviewProvider {
//    static let cols = PreviewUtils.allCollections
//    
//    @ViewBuilder
//    static var previews: some View {
//        print(cols)
//        return CollectionPickerView(collections: cols, selectedCollection: .constant(cols[0]))
//    }
//}

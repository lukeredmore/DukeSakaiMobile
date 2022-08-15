//
//  CollectionPickerView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct CollectionPickerView: View {
    @EnvironmentObject var env : SakaiEnvironment
    
    let completion: () -> Void
    
    func collectionSelected(_ collection: CourseCollection) {
        env.selectedCollection = collection
        completion()
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
    }
    
    @ViewBuilder
    func CourseRow(singleCourseCollection: CourseCollection, favorite: Bool) -> some View {
        HStack {
            Button {
                env.toggleCourseInFavorites(singleCourseCollection.courses[0])
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
                env.selectedCollection = collection
                collectionSelected(collection)
            } label : {
                HeaderRow(collection: collection)
            }
        }
    }
    
    @ViewBuilder
    func SelectableRow(_ course: Course, showFavorites: Bool = false) -> some View {
        let favorite = env.favoritesCollection.courses.contains(course)
        
        if !favorite || showFavorites {
            let singleCourseCollection = CourseCollection(collectionName: course.name,
                                                          courses: [course])
            Button {
                env.selectedCollection = singleCourseCollection
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
                SelectableRow(env.favoritesCollection)
                ForEach(env.favoritesCollection.courses, id: \.siteId) { SelectableRow($0, showFavorites: true) }
                ForEach(env.termCollections, id: \.collectionName) { collection in
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

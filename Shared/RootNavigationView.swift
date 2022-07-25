//
//  RootNavigationView.swift
//  Shared
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct RootNavigationView: View {
    @State private var collections: [CourseCollection]? = nil
    
    
    var body: some View {
        if collections == nil {
                LoginView { cr in
                    if let courses = cr, !courses.isEmpty {
                        print("Got new courses, mocking collection creation now")
//                        if let dobdata = try? JSONEncoder().encode(courses) {
//                            if let json = String(data: dobdata, encoding: .utf8) {
//                                print("Below this line is json string")
//                              print(json)
//                                print("above this line is json string")
//                            }
//                        }
//                        print(courses)
                        var collectionsToSet = [CourseCollection(collectionName: "All Courses", courses: courses)]
                        collectionsToSet.append(contentsOf: Course.organizeByTerm(courses: courses))
                        collections = collectionsToSet
                    } else {
                        print("Got cr but something is wrong: \(cr), logging out")
                    }
                }
        } else {
            HomeTabView(allCollections: Binding($collections)!)
        }
                
    }
        
    
    var body2: some View {
        NavigationView {
            VStack {
                LoginView { cr in
                    if let courses = cr, !courses.isEmpty {
                        print("Got new courses, mocking collection creation now")
                        print(courses)
                        var collectionsToSet = [CourseCollection(collectionName: "All Courses", courses: courses)]
                        collectionsToSet.append(contentsOf: Course.organizeByTerm(courses: courses))
                        collections = collectionsToSet
                    } else {
                        print("Got cr but something is wrong: \(cr), logging out")
                    }
                }
                .navigationBarHidden(true)
                .navigationTitle("")
                if let _ = collections {
                    NavigationLink("",
                                   destination: HomeTabView(allCollections: Binding($collections)!),
                                   isActive: .constant(true))
                }
            }
        }
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}

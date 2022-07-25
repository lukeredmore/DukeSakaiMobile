//
//  RootNavigationView.swift
//  Shared
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct RootNavigationView: View {
    @State private var allCourses: [Course]? = nil
    
    var body: some View {
        if allCourses == nil {
            LoginView { cr in
                if let courses = cr, !courses.isEmpty {
                    print("Got courses from login")
                    allCourses = courses
                } else {
                    print("Got cr but something is wrong: \(cr), logging out")
                    allCourses = nil
                }
            }
        } else {
            CollectionCoordinatorView(Binding($allCourses)!)
        }
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}

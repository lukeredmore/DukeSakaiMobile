//
//  ResourceOverviewView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/30/22.
//

import SwiftUI

struct ResourceOverviewView: View {
    @EnvironmentObject var env : SakaiEnvironment
    
    var body: some View {
        if env.selectedCollection.courses.count == 1 {
            AsyncContentView(loader: ResourceRetriever.getResources, content: ResourcesNavigationView.build)
        } else {
            List(env.selectedCollection.courses, id: \.siteId) { course in
                NavigationLink {
                    AsyncContentView(loader: ResourceRetriever.getResources,
                                     content: ResourcesNavigationView.build)
                    .navigationTitle(course.name)
                    .environmentObject(SakaiEnvironment.create(withCourse: course))
                } label: {
                    Image(systemName: "folder.fill")
                    Text(course.name)
                        .font(.body)
                }
                
                
            }
        }
    }
}

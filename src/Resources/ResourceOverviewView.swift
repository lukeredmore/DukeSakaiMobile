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
            CollectionPickerWrapper() {
                List(env.selectedCollection.courses, id: \.siteId) { course in
                    NavigationLink {
                        AsyncContentView(loader: ResourceRetriever.getResources,
                                         content: ResourcesNavigationView.build,
                                         contentOnly: true)
                        .navigationTitle(course.name)
                        .environmentObject(SakaiEnvironment.create(withCourse: course))
                    } label: {
                        Image(systemName: "folder.fill")
                            .foregroundColor(Color("DukeNavy"))
                        Text(course.name)
                            .font(.body)
                    }
                }
            }
        }
    }
}

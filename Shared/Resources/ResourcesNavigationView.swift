//
//  ResourcesNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct ResourcesNavigationView: View {
    var collection : CourseCollection
    @State private var resources: [Resource]? = nil
    
    @ViewBuilder
    var decider : some View {
        if resources == nil {
            ProgressView()
                .onAppear {
                    ResourceRetriever.getResources(for: collection) { res in
                        resources = res ?? []
                    }
                }
        } else if resources!.isEmpty {
            Text("No resources found")
        } else {
            List(resources!, children: \.children) { item in
                if item.type == "collection" {
                    Image(systemName: item.icon)
                    Text(item.title)
                } else {
                    ZStack {
                        NavigationLink(destination: ResourceDetailView(resource: item)
                            .navigationTitle(item.title)) {  EmptyView() }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                        
                        
                        HStack {
                            Image(systemName: item.icon)
                            Text(item.title)
                                .font(.body)
                            Spacer()
                        }
                    }
                }
                
            }
        }
    }
    
    var body: some View {
        decider.onChange(of: collection) { col in
            print("col changed to \(col)")
            resources = nil
            ResourceRetriever.getResources(for: col) { res in
                resources = res ?? []
            }
        }
    }
}

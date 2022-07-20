//
//  ResourcesNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct ResourcesNavigationView: View {
    var siteId: String
    @State private var resources: [Resource]? = nil
    
    
    @ViewBuilder
    var decider : some View {
        if resources == nil {
            ProgressView()
                .onAppear {
                    ResourceRetriever.getResources(forSiteId: siteId) { res in
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
        decider.onChange(of: siteId) { id in
            print("id changed to \(id) or \(siteId)")
            resources = nil
            ResourceRetriever.getResources(forSiteId: id) { res in
                resources = res ?? []
            }
        }
    }
}

struct ResourcesNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesNavigationView(siteId: "")
    }
}

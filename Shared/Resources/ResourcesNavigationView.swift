//
//  ResourcesNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct ResourcesNavigationView: View {
    var resources: [Resource]
    
    @ViewBuilder
    static func build(_ item: [Resource]) -> some View {
        if item.isEmpty {
            Text("No resources found")
        } else {
            ResourcesNavigationView(resources: item)
        }
    }
    
    var body: some View {
        List(resources, children: \.children) { item in
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

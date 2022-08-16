//
//  ResourcesNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct ResourcesNavigationView: View {
    var resources: [Resource]
    
    @State private var isPresented = false
    
    @ViewBuilder
    static func build(_ item: [Resource]) -> some View {
        if item.isEmpty {
            Text("No resources found")
        } else {
            ResourcesNavigationView(resources: item)
        }
    }
    
    @ViewBuilder
    func externalUrlItem(item: Resource) -> some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: item.icon)
                    .foregroundColor(Color("DukeNavy"))
                Text(item.title)
                    .font(.body)
                Spacer()
            }
        }.sheet(isPresented: $isPresented) {
            SafariView(url: URL(string: item.webUrl!)!)
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    func resourceDetailItem(item: Resource) -> some View {
        ZStack {
            NavigationLink(destination: ResourceDetailView(resource: item)
                .navigationTitle(item.title)) {  EmptyView()  }
                .opacity(0.0)
                .buttonStyle(.plain)
            
            HStack {
                Image(systemName: item.icon)
                    .foregroundColor(Color("DukeNavy"))
                Text(item.title)
                    .font(.body)
                Spacer()
            }
        }
    }
    
    var body: some View {
        List(resources, children: \.children) { item in
            if item.type == "collection" {
                Image(systemName: item.icon)
                    .foregroundColor(Color("DukeNavy"))
                Text(item.title)
            } else if let _ = item.webUrl {
                externalUrlItem(item: item)
            } else {
                resourceDetailItem(item: item)
            }
        }
    }
}

//
//  AssignmentsNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI

struct AssignmentsNavigationView: View {
    var assignments: [Assignment]
    
    @ViewBuilder
    static func build(_ item: [Assignment]) -> some View {
        if item.isEmpty {
            Text("No assignments found")
        } else {
            AssignmentsNavigationView(assignments: item)
        }
    }
    
    var body: some View {
        List(assignments, id: \.title) { item in
            NavigationLink(item.title) {
                AssignmentDetailView(assignment: item)
                    .environmentObject(ImportEnvironment.empty)
            }
        }
    }
}

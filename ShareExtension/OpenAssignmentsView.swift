//
//  OpenAssignmentsView.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import SwiftUI

struct OpenAssignmentsView: View {
    @EnvironmentObject private var env: ImportEnvironment
    
    let assignments: [Assignment]
    
    
    var body: some View {
        if assignments.isEmpty {
            Text("No open assignments found")
        } else {
            List(assignments, id: \.title) { item in
                NavigationLink(item.title) {
                    VStack {
                        Spacer().frame(height: env.headerHeight)
                        AssignmentDetailView(assignment: item)
                    }
                }
            }
        }
    }
}

//struct OpenAssignmentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        OpenAssignmentsView()
//    }
//}

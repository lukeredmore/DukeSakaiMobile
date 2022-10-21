//
//  AttachFileToAssignmentView.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/21/22.
//

import SwiftUI

struct AssignmentLoaderView: View {
    @EnvironmentObject private var env: ImportEnvironment
    
    @State private var authState: AuthState = .idle
    
    @State private var assignments = [Assignment]()
        
    var body: some View {
        if let files = env.files, let scene = env.scene, !files.isEmpty {
                if case .loggedIn = authState {
                    OpenAssignmentsView(assignments: assignments)
                        .frame(maxHeight: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear { Task {
                            do {
                                let courses = try await Authenticator.restoreSession(scene: scene)
                                assignments = try await OpenAssignmentsRetriever.getOpenAssignments()
                                authState = .loggedIn(courses: courses)
                            } catch {
                                print(error)
                                env.showAlert("Could not find any open assignments")
                                env.cancel()
                            }
                        }}
                }
            }
    }
}

//struct AttachFileToAssignmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AttachFileToAssignmentView()
//    }
//}

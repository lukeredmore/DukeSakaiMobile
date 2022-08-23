//
//  AttachFileToAssignmentView.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/21/22.
//

import SwiftUI
import WebKit

struct PreviewWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.load(URLRequest(url: url))
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}


struct AttachFileToAssignmentView: View {
    @EnvironmentObject private var env: ImportEnvironment
    
    @State private var authState: AuthState = .idle
    
    var body: some View {
        if let files = env.files, let scene = env.scene, !files.isEmpty {
            VStack {
                FilePreview(files: files)
                if case .loggedIn(let courses) = authState {
                    Text(courses.joined(separator: ", "))
                        .frame(maxHeight: .infinity)
                } else {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                        .onAppear { Task {
                            do {
                                let courses = try await Authenticator.restoreSession(scene: scene)
                                authState = .loggedIn(courses: courses)
                            } catch {
                                print(error)
                                //TODO: show alert
                                //TODO: Dismiss
                            }
                        }}
                }
            }
        }
    }
}

//struct AttachFileToAssignmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AttachFileToAssignmentView()
//    }
//}

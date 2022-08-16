//
//  SafariView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI
import SafariServices

// A wrapper of SFSafariViewController with no restrictions on navigation
struct SafariView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let url: URL
    
    func makeCoordinator() -> (SafariView.Coordinator) {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.dismissButtonStyle = .close
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) { }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}

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
    
    var body: some View {
        if let files = env.files, !files.isEmpty {
            FilePreview(files: files)
            Spacer()
        }
    }
}

//struct AttachFileToAssignmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AttachFileToAssignmentView()
//    }
//}

//
//  GradeWebView.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/21/22.
//

import SwiftUI
import WebKit

struct GradeWebView: UIViewRepresentable {
//    let request: URLRequest
//
//    init(urlString: String) {
//        "https://sakai.duke.edu/portal/site/7b6f159b-754e-4dda-845e-e04499d4973b/tool/a19ae7ac-1449-44a5-bb1b-106f3a012bed/gradebook"
//    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.copyCookiesFromURLSession()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
//        wv.load(request)
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    typealias UIViewType = WKWebView
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: GradeWebView
        
        init(_ parent: GradeWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("""
                       $('.Mrphs-topHeader').remove();
                       $('.Mrphs-siteHierarchy').remove();
                       $('#toolMenuWrap').remove();
                       $('#skipNav').remove();
                   """) { [weak self] _, _ in
                print("loaded")
//                       self?.onWebViewLoad?()
                   }
        }
    }
    
}

struct GradeWebView_Previews: PreviewProvider {
    static var previews: some View {
        GradeWebView()
    }
}

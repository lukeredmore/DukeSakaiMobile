//
//  GradeWebView.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/21/22.
//

import SwiftUI
import WebKit

struct GradeWebView: UIViewRepresentable {
    let request: URLRequest
    
    init(urlString: String) {
        let url = URL(string: urlString)!
        self.request = URLRequest(url: url)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = CookieMonster.loadSessionCookiesIntoWKWebViewConfig()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.load(request)
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
                   """)
        }
    }
    
}

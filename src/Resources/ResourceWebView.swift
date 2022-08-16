//
//  ResourceWebView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//


import SwiftUI
import WebKit

struct ResourceWebView: UIViewRepresentable {
    var request: URLRequest? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(urlString: String) {
        self.request = URLRequest(url: URL(string: urlString)!)
    }
    
    func makeCoordinator() -> ResourceWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.copyCookiesFromURLSession()
        let wv = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.isOpaque = false
        wv.backgroundColor = UIColor.clear
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let request = request {
            uiView.load(request)
        } else {
            print("how did this happen")
        }
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ResourceWebView
        
        init(_ parent: ResourceWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if let urlString = navigationAction.request.url?.absoluteString,
               urlString.starts(with: "https://sakai.duke.edu") || urlString.starts(with: "https://shib.oit.duke.edu") {
                return .allow
            } else {
                print(navigationAction.request.url!.absoluteString)
                await MainActor.run {
                    UIApplication.shared.open(navigationAction.request.url!)
                    parent.presentationMode.wrappedValue.dismiss()
                }
                return .cancel
            }
        }
    }
}

extension WKWebViewConfiguration {
    func copyCookiesFromURLSession() {
        guard let cookies = URLSession.shared.configuration.httpCookieStorage?.cookies else {
            print("Could not shared cookies")
            return
        }
        for cookie in cookies {
            self.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
    }
}


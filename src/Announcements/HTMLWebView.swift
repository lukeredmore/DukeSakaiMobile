//
//  DynamicWebView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    private var htmlString : String {
    """
    <html lang="en">
       <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
       <style>
            @font-face {
                font-family: 'OpenSans';
                src: url("OpenSans-\(UIAccessibility.isBoldTextEnabled ? "Semibold" : "Regular").ttf") format('truetype');
            }
            :root {
                color-scheme: light dark;
            }
            body {
                font: -apple-system-headline;
                font-family: OpenSans;
                padding: 0.5em 0.75em;
            }
    
            h1 {
                font: -apple-system-headline;
            }
    
            h2 {
                font: -apple-system-subheadline;
            }
    
            footer {
                font: -apple-system-footnote;
            }
    
            a {
                color: \(UIColor.systemBlue.hex);
            }
            img {
                max-width: 100%;
            }
       </style>
       <title>User Guide</title>
       </head>
       <body>
       \(text)
       </body>
    </html>
    """
    }
    
    func makeCoordinator() -> HTMLWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.navigationDelegate = context.coordinator
        wv.isOpaque = false
        wv.backgroundColor = UIColor.clear
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: HTMLWebView
        
        init(_ parent: HTMLWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if let urlString = navigationAction.request.url?.absoluteString,
               urlString.starts(with: "http") {
                await MainActor.run {
                    UIApplication.shared.open(navigationAction.request.url!)
                }
                return .cancel
            } else {
                return .allow
            }
            
        }
    }
}

struct HTMLWebView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLWebView(text: .constant("<h1>Hello world!</h1>"))
    }
}

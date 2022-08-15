//
//  WebView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//


import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var request: URLRequest? = nil
    var fileUrl: URL? = nil
    var onSafariRedirect: (() -> ())? = nil
    
    init(urlString: String, onSafariRedirect: ( () -> ())? = nil) {
        self.request = URLRequest(url: URL(string: urlString)!)
        self.onSafariRedirect = onSafariRedirect
    }
    
    init(fileUrl: URL, onSafariRedirect: ( () -> ())? = nil) {
        self.fileUrl = fileUrl
        self.onSafariRedirect = onSafariRedirect
    }
    
    init(request: URLRequest, onSafariRedirect: ( () -> ())? = nil) {
        self.request = request
        self.onSafariRedirect = onSafariRedirect
    }
    
    func makeCoordinator() -> WebView.Coordinator {
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
        if let request = request {
            uiView.load(request)
        } else if let file = fileUrl {
            uiView.loadFileURL(file, allowingReadAccessTo: file)
        } else {
            print("how did this happen")
        }
         
        

    }
    

        class Coordinator: NSObject, WKNavigationDelegate {
            let parent: WebView

            init(_ parent: WebView) {
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
                        parent.onSafariRedirect?()
                    }
                    return .cancel
                }
            }
        }
}

//struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        DynamicWebView(text: .constant("<h1>Hello world!</h1>"))
//    }
//}


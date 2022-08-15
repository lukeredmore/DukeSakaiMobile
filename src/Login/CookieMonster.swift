//
//  CookieMonster.swift
//  DukeSakai
//
//  Created by Luke Redmore on 8/14/22.
//

import WebKit
import SwiftUI

/* Cookie Monster is an invisible WKWebView who POSTs access token to shib which
 * then redirects to Sakai portal. Once portal is loaded, Cookie Monster steals
 * all the cookies of the WKWebView and copies them to disk and shared URLSession.
 * On restart, Cookie Monster will try to load the saved cookies as a head start
 */
struct CookieMonster: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let request: URLRequest
    let completion: ([String]?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.navigationDelegate = context.coordinator
        wv.isHidden = true
        wv.load(request)
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    static func loadSessionCookiesFromDisk() -> [HTTPCookie]? {
        if let data = UserDefaults.standard.value(forKey: "cookies") as? Data,
           let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] {
            return cookies
        }
        return nil
    }
    
    static func loadSessionCookiesIntoURLSession() {
        if let cookies = loadSessionCookiesFromDisk() {
            for cookie in cookies {
                URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
            }
            print("Injected disk cookies into session")
        } else {
            print("No saved cookies found")
        }
    }
    
    static func saveSessionCookiesToDisk(_ value: [HTTPCookie]) {
        let archivedPool = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        UserDefaults.standard.set(archivedPool, forKey: "cookies")
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: CookieMonster
        
        init(_ parent: CookieMonster) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url, url.absoluteString.hasPrefix("https://sakai.duke.edu/portal") else { return }
            
            // Steal cookies from authnticated Sakai to URLSession
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                CookieMonster.saveSessionCookiesToDisk(cookies)

                cookies.forEach { cookie in
                    URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
                }
                print("Stole cookies from authenticated Sakai in (background) WKWebView and stored them in URLSession and disk")
                Task {
                    let courses = await Authenticator.validateSakaiSession()
                    self.parent.completion(courses)
                }
                
            }
        }
    }
}

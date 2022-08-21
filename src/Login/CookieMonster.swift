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
    
    static func printCookiesAsJson(_ cookies: [HTTPCookie]) {
        /// Wraps `HTTPCookie` in a container which conforms to `Codable` protocol.
        final class CodableHTTPCookieContainer: Codable {
          public enum Error: Swift.Error {
            case failedToUnarchive
          }
          public let cookie: HTTPCookie

          public init(_ cookie: HTTPCookie) {
            self.cookie = cookie
          }

          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let data = try container.decode(Data.self)
            guard let cookie = NSKeyedUnarchiver.unarchiveObject(with: data) as? HTTPCookie else {
              throw Error.failedToUnarchive
            }
            self.cookie = cookie
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let data = NSKeyedArchiver.archivedData(withRootObject: cookie)
            try container.encode(data)
          }
        }
        
        print(cookies.count, "cookies:")
        let codableCookies = cookies.map { CodableHTTPCookieContainer($0) }
        let data = try! JSONEncoder().encode(codableCookies)
        let jsonString = String(data: data,
                                encoding: .utf8)!
        print(jsonString)
    }
    
    static func saveSessionCookiesToDisk(_ cookies: [HTTPCookie]) {
        printCookiesAsJson(cookies)
        let cookiesData = try! NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
        UserDefaults.standard.set(cookiesData, forKey: "cookies")
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

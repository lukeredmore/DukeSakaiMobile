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
 * all the cookies of the WKWebView.
 */
class CookieMonster: WKWebView, WKNavigationDelegate {
    private var continuation: CheckedContinuation<[HTTPCookie], Error>? = nil
    private let cookieUrlPrefix: String
    
    init(frame: CGRect = .zero, configuration: WKWebViewConfiguration = WKWebViewConfiguration(), listeningFor cookieUrlPrefix: String) {
        self.cookieUrlPrefix = cookieUrlPrefix
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAndCollectCookies(_ request: URLRequest) async throws -> [HTTPCookie] {
        print("Loading page to collect cookies")
        load(request)
        //TODO: implement timeout if requested page isn't reached. It's likely this user has a netId but doesn't use Sakai
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url, url.absoluteString.hasPrefix(cookieUrlPrefix) else { return }
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            self.continuation?.resume(returning: cookies)
        }
    }
}

extension CookieMonster {
    private static func loadSessionCookiesFromDisk() -> [HTTPCookie]? {
        if let data = UserDefaults.shared.value(forKey: "cookies") as? Data,
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
    
    static func saveSessionCookiesToDisk(_ cookies: [HTTPCookie]) {
        let cookiesData = try! NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
        UserDefaults.shared.set(cookiesData, forKey: "cookies")
    }
    
    static func loadSessionCookiesIntoWKWebViewConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        guard let cookies = URLSession.shared.configuration.httpCookieStorage?.cookies else {
            print("Could not find shared cookies")
            return config
        }
        for cookie in cookies {
            config.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
        return config
    }
}

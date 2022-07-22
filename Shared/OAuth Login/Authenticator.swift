//
//  Authenticator.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import Foundation

class Authenticator {
    
    static func injectCookiesIntoURLSession(_ cookies: [HTTPCookie]) {
        let session = URLSession.shared

        // Unlike UIWebView, WKWebView doesn't share cookies with URLSession
        // Need to do that manually:
//        cookies.forEach { cookie in
//            session.configuration.httpCookieStorage?.setCookie(cookie)
//        }
    }
}

//
//  Authenticator.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import UIKit
import WebKit

enum AuthState {
    case idle, newUser, loading, loggedIn(courses: [String])
}

class Authenticator {
    // This method should not be called directly, call env.logout() instead
    static func logout() async {
        return await withCheckedContinuation { continuation in
            print("Logging out by removing access token and resetting cookies")
            UserDefaults.shared.removeObject(forKey: "cookies")
            UserDefaults.shared.removeObject(forKey: "accessToken")
            UserDefaults.shared.removeObject(forKey: "sessionToken")
            UserDefaults.shared.removeObject(forKey: "favorite-course-ids")
            URLSession.shared.reset {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    static func restoreSession(scene: UIWindowScene) async throws -> [String] {
        print("Attempting to restore session")
        CookieMonster.loadSessionCookiesIntoURLSession()
        if let courses = await validateSakaiSession() {
            print("Saved session is still valid")
            return courses
        }
        print("Saved session invalid")
        guard let savedAccessToken = UserDefaults.shared.string(forKey: "accessToken"),
              let savedSessionToken = UserDefaults.shared.string(forKey: "sessionToken") else {
            print("No saved access token found. New user?")
            throw AuthenticationError.noAccessToken
        }
        
        print("Found a saved access token. Let's validate it and refresh the session")
        let accessToken = try await refreshAccessTokenIfNecessary(accessToken: savedAccessToken, sessionToken: savedSessionToken)
        let request = buildSakaiAccessRequest(accessToken: accessToken)
        let cookieMonster = CookieMonster(frame: .zero, listeningFor: "https://sakai.duke.edu/portal")
        let window = scene.windows.first!
        window.addSubview(cookieMonster)
        let cookies = try await cookieMonster.loadAndCollectCookies(request)
        print("Created valid session and stole its cookies")
        CookieMonster.saveSessionCookiesToDisk(cookies)
        cookies.forEach { cookie in
            URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)
        }
        print("Saved cookies to disk and copied them to URLSession")
        cookieMonster.removeFromSuperview()
        if let courses = await validateSakaiSession() {
            print("Restored session successfully")
            return courses
        } else {
            print("Unknown authentication error")
            throw AuthenticationError.unknown
        }
    }
    
    static func validateSakaiSession() async -> [String]? {
        do {
            let courses = try await getCourseList()
            return courses.isEmpty ? nil : courses
        } catch {
            print(error)
            return nil
        }
    }
    
    private static func getCourseList() async throws -> [String] {
        let json = try await Networking.json(from: URL(string: "https://sakai.duke.edu/direct/membership.json?_limit=100")!)
        let membershipCollection : [[String: AnyObject]] = try json.get("membership_collection")
        
        //TODO: do i need to get userid here
        return membershipCollection.compactMap { membership in
            guard let id = try? membership.get("id", as: String.self) else { return nil }
            return id.components(separatedBy: "site:")[1]
        }
    }
    
    private static func refreshAccessTokenIfNecessary(accessToken: String, sessionToken: String) async throws -> String {
        if !validateAccessToken(accessToken) {
            print("Access token is invalid, refreshing")
            return try await refreshAccessToken(accessToken: accessToken, sessionToken: sessionToken)
        } else {
            print("Access token is valid, no need to refresh")
            return accessToken
        }
    }
    
    private static func refreshAccessToken(accessToken: String, sessionToken: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://mobile-authorizer.oit.duke.edu/dukemobile/refresh")!)
        request.httpMethod = "POST"
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        request.setValue(sessionToken, forHTTPHeaderField: "x-session-token")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse,
           response.statusCode == 200,
           let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
           let data = json["data"] as? [String: AnyObject],
           let accessToken = data["access_token"] as? String,
           let sessionToken = data["session_token"] as? String {
            UserDefaults.shared.set(accessToken, forKey: "accessToken")
            UserDefaults.shared.set(sessionToken, forKey: "sessionToken")
            print("Refreshed access token")
            return accessToken
        } else {
            throw AuthenticationError.couldNotRefreshAccessToken
        }
        
    }
    
    private static func validateAccessToken(_ token: String) -> Bool {
        let tokenParts: [[String: AnyObject]?] = token.split(separator: ".").map { encodedPart in
            guard let bodyData = Data(base64Encoded: String(encodedPart), autoPadding: true),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
                  let payload = json as? [String: AnyObject] else {
                return nil
            }
            return payload
        }
        
        if let tokenBody = tokenParts[1],
           let exp = tokenBody["exp"] as? TimeInterval  {
            let expDate = Date(timeIntervalSince1970: exp)
            if expDate > Date() {
                return true
            }
        }
        return false
    }
    
    private static func buildSakaiAccessRequest(accessToken: String) -> URLRequest {
        let authURLString = "https://shib.oit.duke.edu/idp/oauth/oauthtokensso"
        let url = URL(string: authURLString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let params = [
            "entityId":  "https://duke-prod.saml.longsight.com/samlauth",
            "accessToken":  accessToken
        ]
        request.httpBody = params.percentEncoded()
        return request
    }
}

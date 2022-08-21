//
//  Authenticator.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import Foundation
import WebKit

enum AuthState {
    case idle, invalidAccessToken, noAccessToken, loggingOut, invalidSession(refreshSessionRequest: URLRequest)
    case loggedIn(courses: [String])
}

class Authenticator {
    // This method should not be called directly, call env.logout() instead
    static func logout() async {
        return await withCheckedContinuation { continuation in
            print("Logging out by removing access token and resetting cookies")
            UserDefaults.standard.removeObject(forKey: "cookies")
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "sessionToken")
            UserDefaults.standard.removeObject(forKey: "favorite-course-ids")
            URLSession.shared.reset {
                continuation.resume()
            }
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
    
    static func getCourseList() async throws -> [String] {
        let json = try await Networking.json(from: URL(string: "https://sakai.duke.edu/direct/membership.json?_limit=100")!)
        let membershipCollection : [[String: AnyObject]] = try json.get("membership_collection")
        
        //TODO: do i need to get userid here
        return membershipCollection.compactMap { membership in
            guard let id = try? membership.get("id", as: String.self) else { return nil }
            return id.components(separatedBy: "site:")[1]
        }
    }
    
    static func refreshAccessToken(accessToken: String, sessionToken: String) async throws -> String {
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
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
            UserDefaults.standard.set(sessionToken, forKey: "sessionToken")
            print("Refreshed access token")
            return accessToken
        } else {
            throw SakaiError.other("Failed to refresh token")
        }

    }
    
    static func validateAccessToken(_ token: String) -> Bool {
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
    
    static func buildSakaiAccessRequest(accessToken: String) -> URLRequest {
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

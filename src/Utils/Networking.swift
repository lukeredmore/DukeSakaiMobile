//
//  Networking.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import Foundation

class Networking {
    static private let SAKAI_DIRECT_URL = "https://sakai.duke.edu/direct/"
    
    static func createSakaiURL(siteId: String, endpoint: String, options: [String: String], siteSpecific: Bool = true) throws -> URL {
        let baseURLString = SAKAI_DIRECT_URL + endpoint + (siteSpecific ? "/site/" : "/") + siteId + ".json"
        guard let baseURL = URL(string: baseURLString) else { throw SakaiDataRetrievalError.invalidRequestUrl }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = options.map {
            URLQueryItem(name: "\($0)", value: "\($1)")
        }
        guard let finalUrl = components?.url else {
            throw SakaiDataRetrievalError.invalidRequestUrlWithComponents
        }
        return finalUrl
    }
    
    static func json(from requestUrl: URL) async throws -> [String: AnyObject] {
        let (data, _) = try await URLSession.shared.data(from: requestUrl)
        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
            throw SakaiDataRetrievalError.failedToParseDataAsJson
        }
        return json
    }
}

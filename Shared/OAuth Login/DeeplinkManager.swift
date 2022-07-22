//
//  DeeplinkManager.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import Foundation

class DeeplinkManager {
    
    enum DeeplinkTarget: Equatable {
        case home
        case details(reference: String)
    }
    
    class DeepLinkConstants {
        static let scheme = "dukesakaimobile"
        static let host = "com.lukeredmore.dukesakaimobile"
        static let authPath = "/auth"
        static let query = "id"
    }
    
    func manage(url: URL) -> DeeplinkTarget {
        print("wer rec3ived  a alink")
        
        guard url.scheme == DeepLinkConstants.scheme,
              url.host == DeepLinkConstants.host,
              url.path == DeepLinkConstants.authPath,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else { return .home }
        
        print(queryItems)
        let query = queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        guard let id = query[DeepLinkConstants.query] else { return .home }
        
        return .details(reference: id)
    }
}

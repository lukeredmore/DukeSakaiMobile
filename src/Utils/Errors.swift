//
//  Errors.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/21/22.
//

import Foundation

enum SakaiDataRetrievalError: Error {
    case failedToParseDataAsJson
    case invalidRequestUrl
    case invalidRequestUrlWithComponents
    case failedToFindKeyInJson(key: String)
    case failedToParseKeyInJsonAsType(key: String)
}

enum SakaiError: Error {
    case importError
    case other(String)
}

enum AuthenticationError: Error {
    case noAccessToken
    case couldNotRefreshAccessToken
    case unknown
}

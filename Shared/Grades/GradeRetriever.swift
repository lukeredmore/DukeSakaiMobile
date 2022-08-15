//
//  GradeRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/26/22.
//

import Foundation

struct GradeItem {
    let itemName: String
    let grade, points: Double
    let course: Course
}

class GradeRetriever {
    static func getGrades(for collection: CourseCollection) async throws {//} -> [GradeItem] {
        print("Starting to get grades")
        
        let url = try createURL(siteId: collection.courses[0].siteId, endpoint: "grades/gradebook", options: [:])
        print(url)
        let json = try await json(from: url)
        print(json)
        
    }
    
    enum SakaiDataRetrievalError: Error {
        
        case failedToParseDataAsJson
        case invalidRequestUrl
        case invalidRequestUrlWithComponents
    }
    
    private static let SAKAI_DIRECT_URL = "https://sakai.duke.edu/direct/"
    
    private static func createURL(siteId: String, endpoint: String, options: [String: String]) throws -> URL {
        let baseURLString = SAKAI_DIRECT_URL + endpoint + "/site/" + siteId + ".json"
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
    
    private static func json(from requestUrl: URL) async throws -> [String: AnyObject] {
        let (data, _) = try await URLSession.shared.data(from: requestUrl)
        guard let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: AnyObject] else {
            throw SakaiDataRetrievalError.failedToParseDataAsJson
        }
        return json
        
    }
    
    private static func getJSONFrom(_ requestUrl: URL, completion: @escaping ([String: AnyObject]?) -> Void) {
        let task = URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            do {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let data = data,
                   let fullJson = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: AnyObject] {
                    completion(fullJson)
                } else {
                    completion(nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }
        task.resume()
    }
    
}

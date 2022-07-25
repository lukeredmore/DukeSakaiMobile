//
//  Networking.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import Foundation

class Networking {
    
    static private let SAKAI_DIRECT_URL = "https://sakai.duke.edu/direct/"
    
    static func createURL(siteId: String, endpoint: String, options: [String: String]) -> URL? {
        let baseURLString = SAKAI_DIRECT_URL + endpoint + "/site/" + siteId + ".json"
        guard let baseURL = URL(string: baseURLString) else { return nil }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = options.map {
            URLQueryItem(name: "\($0)", value: "\($1)")
        }
        return components?.url
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
    
    
    static func getJSONArrayAt(_ endpoint: String,
                               from courses: [Course],
                               aggregatingBy aggregation: String,
                               withOptions options: [String: String] = [:],
                               completion: @escaping ([[String: AnyObject]]) -> Void) {
        let group = DispatchGroup()
        var aggregatedArray = [[String: AnyObject]]()
        
        for course in courses {
            group.enter()
            if let url = createURL(siteId: course.siteId, endpoint: endpoint, options: options) {
                print(url.absoluteString)
                getJSONFrom(url) { json in
                    if let json = json {
                        print("Task \(course.name) is done")
                        if let child = json[aggregation] as? [[String: AnyObject]] {
                            aggregatedArray.append(contentsOf: child)
                        } else {
                            print("Got json, but couldn't append its \(aggregation) to array")
                        }
                    } else {
                        print("Task \(course.name) return nil json")
                    }
                    group.leave()
                }
            } else {
                print("URL was nil")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("Aggregated array for \(aggregation)")
            completion(aggregatedArray)
        }
    }
}

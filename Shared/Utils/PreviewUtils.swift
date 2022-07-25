//
//  PreviewUtils.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/24/22.
//

import Foundation

class PreviewUtils {
    static var courseList : [Course] {
        if let path = Bundle.main.path(forResource: "courses", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                return try decoder.decode([Course].self, from: data)
            } catch {
                print(error)
                return []
            }
        } else {
            return []
        }
    }
    
    static var allCollections: [CourseCollection] {
        var ret = [CourseCollection(collectionName: "All Courses", courses: courseList)]
        ret.append(contentsOf: Course.organizeByTerm(courses: courses))
        return ret
    }
    
    static func printAsJson<T: Encodable>(obj: T) {
        if let dobdata = try? JSONEncoder().encode(obj) {
                                    if let json = String(data: dobdata, encoding: .utf8) {
                                        print("Below this line is json string")
                                      print(json)
                                        print("above this line is json string")
                                    }
                                }
                                print(courses)
    }
}

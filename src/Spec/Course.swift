//
//  Course.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import Foundation

struct CourseCollection: Equatable {
    static func == (lhs: CourseCollection, rhs: CourseCollection) -> Bool {
        lhs.collectionName == rhs.collectionName && rhs.courses == lhs.courses
    }
    
    let collectionName: String, courses: [Course]
    
    init(collectionName: String, courses: [Course]) {
        self.collectionName = collectionName
        self.courses = courses
    }
    
    init() {
        self.collectionName = ""
        self.courses = []
    }
}

class Course: Equatable, Codable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        lhs.siteId == rhs.siteId
    }
    
    let name: String, siteId: String, term: String, instructor: String, lastModified: Int64, created: Int64, gradebookUrl: String?
    
    init(name: String, siteId: String, term: String, instructor: String, lastModified: Int64, created: Int64, gradebookUrl: String?) {
        self.name = name
        self.siteId = siteId
        self.term = term
        self.instructor = instructor
        self.lastModified = lastModified
        self.created = created
        self.gradebookUrl = gradebookUrl
    }
}

//
//  Course.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import Foundation

class CourseCollection: Equatable {
    static func == (lhs: CourseCollection, rhs: CourseCollection) -> Bool {
        lhs.collectionName == rhs.collectionName && rhs.courses == lhs.courses
    }
    
    let collectionName: String, courses: [Course]
    
    init(collectionName: String, courses: [Course]) {
        self.collectionName = collectionName
        self.courses = courses
    }
}

class Course: Equatable, Codable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        lhs.siteId == rhs.siteId
    }
    
    let name: String, siteId: String, term: String, instructor: String, lastModified: Int64, created: Int64
    
    init(name: String, siteId: String, term: String, instructor: String, lastModified: Int64, created: Int64) {
        self.name = name
        self.siteId = siteId
        self.term = term
        self.instructor = instructor
        self.lastModified = lastModified
        self.created = created
    }
    
    static func organizeByTerm(courses: [Course]) -> [CourseCollection] {
        var coursesByTerm = [String : [Course]]()
        for course in courses {
            coursesByTerm[course.term, default: []].append(course)
        }
        
        var collectionsToReturn = [CourseCollection]()
        for (term, courses) in coursesByTerm {
            if term == "Project" { continue }
            collectionsToReturn.append(CourseCollection(collectionName: term, courses: courses))
        }
        collectionsToReturn = collectionsToReturn.sorted { a, b in
            a.courses[0].created > b.courses[0].created
        }
        if let project = coursesByTerm["Project"] {
           collectionsToReturn.append(CourseCollection(collectionName: "Projects", courses: project))
        }
        return collectionsToReturn
    }
}

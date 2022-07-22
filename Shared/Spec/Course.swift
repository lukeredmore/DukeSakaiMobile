//
//  Course.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import Foundation

struct CourseCollection: Equatable {
    let collectionName: String, courses: [Course]
    
    static func previewDefault() -> [CourseCollection] {
        [CourseCollection(collectionName: "All Courses", courses: [Course.previewDefault()]),
         CourseCollection(collectionName: "Another set of courses", courses: [Course.previewDefault()])]
    }
}

struct Course: Equatable {
    let name: String, siteId: String, term: String, instructor: String, lastModified: Int64, created: Int64
    
    static func previewDefault() -> Course {
        Course(name: "Test Course", siteId: "jksd-3jkdq-paecb-ddopi", term: "Never 1991", instructor: "Luke Redmore", lastModified: 2233222, created: 2233220)
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

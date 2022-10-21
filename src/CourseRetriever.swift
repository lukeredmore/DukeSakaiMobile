//
//  CourseRetriever.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/30/22.
//

import Foundation

class CoursesRetriever {
    static func getCourses(for siteIds: [String]) async throws -> [Course] {
        print("Loading courses for all siteIds")
        
        let courses = try await withThrowingTaskGroup(of: Course.self) { taskGroup -> [Course] in
            for siteId in siteIds {
                taskGroup.addTask {
                    return try await getCourse(for: siteId)
                }
            }
            
            var allCourses = [Course]()
            for try await course in taskGroup {
                allCourses.append(course)
            }
            return allCourses
        }
        
        print("Loaded \(courses.count) courses belong to the user")
        return courses
    }
    
    private static func getCourse(for siteId: String) async throws -> Course {
        do {
            let url = try Networking.createSakaiURL(siteId: siteId,
                                                    endpoint: "site",
                                                    options: ["n": "200", "d": "3000"],
                                                    siteSpecific: false)
            let json = try await Networking.json(from: url)
            let pages: [[String: AnyObject]] = try json.get("sitePages")
            let gradebookPage = pages.first { page in
                let title: String? = try? page.get("title")
                return title == "Course Grades" || title == "Gradebook" || title == "Grades"
            }
            return Course(name: try json.get("title"),
                          siteId: siteId,
                          term: try json.get("type") != "project" ? json.get(["props", "term"]) : "Project",
                          instructor: try json.get(["siteOwner", "userDisplayName"]),
                          lastModified: try json.get("lastModified"),
                          created: try json.get("createdDate"),
                          gradebookUrl: try gradebookPage?.get("url"))
        } catch {
            print("Error in getting course \(siteId): \(error)")
            throw error
        }
    }
    
    static func groupCourses(courses: [Course]) -> (termCollections: [CourseCollection], favoritesCollection: CourseCollection) {
        print("Aggregating courses into collections")
        let termCollections = organizeCoursesByTerm(courses: courses)
        
        let favorites = UserDefaults.shared.array(forKey: "favorite-course-ids") as? [String] ?? []
        let favoriteCourses = courses.filter { course in
            favorites.contains(course.siteId)
        }
        let favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favoriteCourses)
        
        return (termCollections, favoritesCollection)
    }
    
    private static func organizeCoursesByTerm(courses: [Course]) -> [CourseCollection] {
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

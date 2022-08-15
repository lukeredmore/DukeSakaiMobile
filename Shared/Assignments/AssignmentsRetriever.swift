//
//  AssignmentsRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/24/22.
//

import SwiftUI


struct Assignment {
    var title: String
    var status: String?
    var scale: String?
    var instructions: String
    var dueAt: Date?
}

class AssignmentsRetriever {
    private static func getAssignments(forSiteId siteId: String) async throws -> [Assignment] {
        let url = try Networking.createSakaiURL(siteId: siteId, endpoint: "assignment", options: [:])
        let json = try await Networking.json(from: url)
        let assignment_collection : [[String: AnyObject]] = try json.get("assignment_collection")
        
        var assignments = [Assignment]()
        for entry in assignment_collection {
            do {
                assignments.append(Assignment(title: try entry.get("title"),
                           status: try entry.get("status"),
                           scale: try entry.get("gradeScaleMaxPoints"),
                           instructions: try entry.get("instructions"),
                           dueAt: try Date(try entry.get("dueTimeString"), strategy: .iso8601)))
            } catch {
                print(error)
            }
        }
        return assignments
    }
    
    static func getAssignments(for collection: CourseCollection) async throws -> [Assignment] {
        print("Loading assignments for collection \(collection.collectionName)")
        
        var allAssignments = [Assignment]()
        try await withThrowingTaskGroup(of: [Assignment].self) { taskGroup in
            for course in collection.courses {
                taskGroup.addTask {
                    try await getAssignments(forSiteId: course.siteId)
                }
                for try await result in taskGroup {
                    allAssignments.append(contentsOf: result)
                }
            }
        }
        
        print("Loaded \(allAssignments.count) assignments for collection \(collection.collectionName)")
        return allAssignments
    }
}


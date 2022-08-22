//
//  AssignmentsRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/24/22.
//

import SwiftUI


struct Assignment {
    var title: String
    var id: String
    var status: String?
    var scale: String?
    var directUrl: URL
    var instructions: String
    var submissionType: String
    var dueAt: Date?
    
    static func build(from json: [String: AnyObject]) throws -> Assignment {
        return Assignment(title: try json.get("title"),
                          id: try json.get("id"),
                          status: try json.get("status"),
                          scale: try json.get("gradeScaleMaxPoints"),
                          directUrl: URL(string: try json.get("entityURL"))!,
                          instructions: try json.get("instructions"),
                          submissionType: try json.get("submissionType"),
                          dueAt: try Date(try json.get("dueTimeString"), strategy: .iso8601))
    }
}

class AssignmentsRetriever {
    private static func getAssignments(forSiteId siteId: String) async throws -> [Assignment] {
        let url = try Networking.createSakaiURL(siteId: siteId, endpoint: "assignment", options: [:])
        let json = try await Networking.json(from: url)
        let assignment_collection : [[String: AnyObject]] = try json.get("assignment_collection")
        
        var assignments = [Assignment]()
        for entry in assignment_collection {
            do {
                let assignment = try Assignment.build(from: entry)
                assignments.append(assignment)
            } catch {
                print("Failed to get assignment with error:", error.localizedDescription)
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


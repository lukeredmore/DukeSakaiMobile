//
//  OpenAssignmentsRetriever.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import Foundation

class OpenAssignmentsRetriever {

    static func getOpenAssignments() async throws -> [Assignment] {
        guard let url = URL(string: "https://sakai.duke.edu/direct/assignment/my.json") else { throw SakaiDataRetrievalError.invalidRequestUrl }
        let json = try await Networking.json(from: url)
        var assignment_collection : [[String: AnyObject]] = try json.get("assignment_collection")
        assignment_collection = assignment_collection.filter { entry in
            let status = try? entry.get("status", as: String.self)
            return status == "OPEN"
            //TODO: Verify attachment submission type
        }
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
}

//
//  AssignmentsRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/24/22.
//

import SwiftUI


struct Assignment {
    var title: String
    var status: String
    var scale: String
    var instructions: String
    var dueAt: Date
}

class AssignmentsRetriever {
    static func getAssignments(for col: CourseCollection) async throws -> [Assignment] {
        await withCheckedContinuation { continuation in
            getAssignments(for: col) { assgn in
                    continuation.resume(returning: assgn ?? [])
               
            }
        }
        
    }
    
    private static func getAssignments(for col: CourseCollection, completion: @escaping ([Assignment]?) -> Void) {
        Networking.getJSONArrayAt("assignment",
                                  from: col.courses,
                                  aggregatingBy: "assignment_collection") { jsonArray in
            print("Loading assignments")
            var assignmentItems = [Assignment]()
            for assn in jsonArray {
                var title:String = "Not Available"
                var status:String = "Not Available"
                var dueTimeString:String = "Not Available"
                var dueTime:Int64 = 0
                var gradeScaleMaxPoints:String = "Not Available"
                var instructions:String = "<h5>Not Available</h5>"
                
                if let mytitle = assn["title"] as? String {
                    title = (mytitle == "" ? "Not Available" : mytitle)
                }
                if let mystatus = assn["status"] as? String {
                    status = (mystatus == "" ? "Not Available" : mystatus)
                }
                if let mydueTimeString = assn["dueTimeString"] as? String {
                    dueTimeString = (mydueTimeString == "" ? "Not Available" : mydueTimeString)
                }
                if let tempDue = assn["dueTime"]  {
                    dueTime = (tempDue["epochSecond"] as? Int64) ?? 0
//                    dueTimeString = self.ReadableDate(date: NSDate(timeIntervalSince1970: TimeInterval(dueTime)))
                }
                if let mygradeScaleMaxPoints = assn["gradeScaleMaxPoints"] as? String {
                    gradeScaleMaxPoints = (mygradeScaleMaxPoints == "" ? "Not Available" : mygradeScaleMaxPoints)
                }
                if let myinstructions = assn["instructions"] as? String {
                    instructions = (myinstructions == "" ? "<h5>Not Available</h5>" : myinstructions)
                }
                let tuple = (title, status, dueTimeString, gradeScaleMaxPoints, instructions, dueTime)
                
                assignmentItems.append(Assignment(title: title,
                                                       status: status,
                                                       scale: gradeScaleMaxPoints,
                                                       instructions: instructions,
                                                       dueAt: Date(timeIntervalSince1970: Double(dueTime))))
            }
            completion(assignmentItems)
            
        }
    }
    
    
    
}


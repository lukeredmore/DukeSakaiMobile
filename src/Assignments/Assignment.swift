//
//  Assignment.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import Foundation

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

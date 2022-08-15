//
//  AnnouncementsRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import SwiftUI

struct Announcement: Identifiable, Comparable, Codable {
    // TODO: Add attachments as [Resource]
    let id: String
    let title: String
    let author: String
    let body: String
    let courseTitle: String
    let siteId: String
    let createdOn: Date
        
    var timePostedString : String {
        if Calendar.current.isDateInToday(createdOn) {
            return DateFormatter.localizedString(from: createdOn, dateStyle: .none, timeStyle: .short)
        } else if Calendar.current.isDateInYesterday(createdOn) {
            return "Yesterday"
        } else if Calendar.current.dateComponents([.day], from: createdOn, to: Date()).day ?? 9 < 8 {
            let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "EEEE"
                   return dateFormatter.string(from: Date())
        } else {
            return DateFormatter.localizedString(from: createdOn, dateStyle: .short, timeStyle: .none)
        }
    }
    
    static func < (lhs: Announcement, rhs: Announcement) -> Bool {
        lhs.createdOn > rhs.createdOn
    }
    
}

class AnnouncementsRetriever {
    private static func getAnnouncements(forSiteId siteId: String) async throws -> [Announcement] {
        let url = try Networking.createSakaiURL(siteId: siteId,
                                                endpoint: "announcement",
                                                options: ["n": "200", "d": "3000"])
        guard let json = try? await Networking.json(from: url) else {
            print("No json found at URL. This should be a rare occurrence, does the page not exist?")
            return []
        }
        let announcement_collection : [[String: AnyObject]] = try json.get("announcement_collection")
        var announcements = [Announcement]()
        for entry in announcement_collection {
            do {
                var courseTitle : String = try entry.get("siteTitle")
                let split = courseTitle.split(separator: ".")
                if split.count > 1 {
                     courseTitle = "\(split[0]) \(split[1])"
                }
                announcements.append(Announcement(id: try entry.get("announcementId"),
                                              title: try entry.get("title"),
                                              author: try entry.get("createdByDisplayName"),
                                              body: try entry.get("body"),
                                              courseTitle: courseTitle,
                                              siteId: try entry.get("siteId"),
                                              createdOn: Date(timeIntervalSince1970: TimeInterval(try entry.get("createdOn", as: Double.self)/1000.0))))
            } catch {
                print(error)
            }
        }
        return announcements
    }
    
    // TODO: Aggregate with email archive
    static func getAnnouncements(for collection: CourseCollection) async throws -> [Announcement] {
        print("Loading announcements for collection \(collection.collectionName)")
        
        var annoucements = try await withThrowingTaskGroup(of: [Announcement].self) { taskGroup -> [Announcement] in
            var allAnnouncements = [Announcement]()
            
            for course in collection.courses {
                taskGroup.addTask {
                    return try await getAnnouncements(forSiteId: course.siteId)
                }
            }
            
            for try await courseAnnoucements in taskGroup {
                allAnnouncements.append(contentsOf: courseAnnoucements)
            }
            return allAnnouncements
        }
        
        print("Loaded all \(annoucements.count) announcements for collection \(collection.collectionName)")
        annoucements.sort()
        return annoucements
    }
}

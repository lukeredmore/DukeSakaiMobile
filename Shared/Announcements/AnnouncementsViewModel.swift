//
//  AnnouncementsRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import SwiftUI

struct Announcement: Identifiable, Comparable, Codable {
    static func < (lhs: Announcement, rhs: Announcement) -> Bool {
        lhs.createdOn > rhs.createdOn
    }
    
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
    
}

class AnnoucementsViewModel: LoadableObject {
    @Published private(set) var state: LoadingState<[Announcement]> = .idle
    
    let collection: CourseCollection
    init(_ collection: CourseCollection) {
        self.collection = collection
    }
    
    func load() {
        state = .loading
        print("requested to load")
        getAnnouncements(for: collection) { res in
            if res == nil {
                self.state = .failed("It was nil")
            } else {
                self.state = .loaded(res!)
            }
        }
    }
    
    
    private func getAnnouncements(for collection: CourseCollection, completion: @escaping ([Announcement]?) -> Void) {
        Networking.getJSONArrayAt("announcement",
                                  from: collection.courses,
                                  aggregatingBy: "announcement_collection",
                                  withOptions: ["n": "200", "d": "3000"]) { jsonArray in
            var announcements = [Announcement]()
            for announcementEntry in jsonArray {
                guard let title = announcementEntry["title"] as? String,
                      let id = announcementEntry["announcementId"] as? String,
                      let body = announcementEntry["body"] as? String,
                      let author = announcementEntry["createdByDisplayName"] as? String,
                      let createdOn = announcementEntry["createdOn"] as? Int64,
                      var courseTitle = announcementEntry["siteTitle"] as? String,
                      let siteId = announcementEntry["siteId"] as? String
                else {
                    print("AN ANNOUCEMENT WAS NIL 2")
                    continue
                }
                let split = courseTitle.split(separator: ".")
                if split.count > 1 {
                     courseTitle = "\(split[0]) \(split[1])"
                }
                announcements.append(Announcement(id: id,
                                                  title: title,
                                                  author: author,
                                                  body: body,
                                                  courseTitle: courseTitle,
                                                  siteId: siteId,
                                                  createdOn: Date(timeIntervalSince1970: TimeInterval(Double(createdOn)/1000.0))))
            }
            announcements.sort()
            completion(announcements)
        }
    }
}

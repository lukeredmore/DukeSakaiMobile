//import SwiftUI
//import Foundation
//
//struct Course: Equatable, Encodable {
//    let name: String, id: String//, term: String, instructor: String, lastModified: Int64, created: Int64
//
////    static func organizeByTerm(courses: [Course]) -> [CourseCollection] {
////        var coursesByTerm = [String : [Course]]()
////        for course in courses {
////            coursesByTerm[course.term, default: []].append(course)
////        }
////
////        var collectionsToReturn = [CourseCollection]()
////        for (term, courses) in coursesByTerm {
////            if term == "Project" { continue }
////            collectionsToReturn.append(CourseCollection(collectionName: term, courses: courses))
////        }
////        collectionsToReturn = collectionsToReturn.sorted { a, b in
////            a.courses[0].created > b.courses[0].created
////        }
////        if let project = coursesByTerm["Project"] {
////           collectionsToReturn.append(CourseCollection(collectionName: "Projects", courses: project))
////        }
////        return collectionsToReturn
////    }
//
//    enum CodingKeys: String, CodingKey {
//        case entityId, title
//      }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decode(String.self, forKey: .title)
//        self.id = try container.decode(String.self, forKey: .entityId)
//
////        var name:String = "name"
////
////        var instructor:String = "instructor"
////        var lastModified:Int64 = 0
////        var term:String = "Project"
////        var created:Int64 = 0
////
////
////        if let type = json["type"] as? String {
////            if (type != "project") {
////                if let props = json["props"]  {
////                    term = (props["term"] as? String)!
////                }
////            }
////        }
////        if let siteOwner = json["siteOwner"]  {
////            if (siteOwner["userDisplayName"] as? String) != nil {
////                instructor = (siteOwner["userDisplayName"] as? String)!
////            }
////        }
////        if let mylastModified = json["lastModified"] as? Int64{
////            lastModified = mylastModified
////        }
////        if let myCreated = json["createdDate"] as? Int64{
////            created = myCreated
////        }
////        courses.append(Course(name: name,
////                              siteId: site,
////                              term: term,
////                              instructor: instructor,
////                              lastModified: lastModified,
////                              created: created));
////        self.name
//    }
//}
//
//guard let fileUrl = Bundle.main.url(forResource: "courses", withExtension: "json"),
//      let jsonData = try String(contentsOf: fileUrl).data(using: .utf8),
//      let fullJson = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: AnyObject],
//      let json = fullJson["content_collection"] as? [[String: AnyObject]] else { fatalError() }
//
//let decoder = JSONDecoder()
//decoder.

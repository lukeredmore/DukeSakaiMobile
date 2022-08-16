//
//  ResourcesRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI


class Resource: Identifiable {
    let numChildren : Int
    let title : String
    let type : String
    let url : String
    let webUrl: String?
    var parent : Resource?
    var children : [Resource]?
    
    var icon: String {
        if children == nil {
            if type == "text/url" {
                return "safari"
            } else if type.hasPrefix("video") {
                return "play.tv"
            } else {
                return "doc"
            }
        } else if children!.isEmpty {
            return "folder"
        } else {
            return "folder.fill"
        }
    }
    
    init(title: String, numChildren: Int, type: String, url: String, webUrl: String? = nil) {
        self.numChildren = numChildren
        self.title = title
        self.type = type
        self.url = url
        self.webUrl = webUrl
        
        children = self.type == "collection" ? [] : nil
    }
    
    fileprivate var treeIds : (parent: String, id: String) {
        var pathString = url.replacingOccurrences(of: "https://sakai.duke.edu/access/content/group/", with: "")
        if pathString.last! == "/" { pathString.removeLast() }
        var pathArray = pathString.split(separator: "/")
        pathArray.removeLast()
        
        return (parent: pathArray.joined(separator: "/"),
                id: pathString)
    }
}

class ResourceRetriever {
    private static func getResources(forSiteId siteId: String) async throws -> [Resource] {
        let url = try Networking.createSakaiURL(siteId: siteId, endpoint: "content", options: [:])
        let json = try await Networking.json(from: url)
        let content_collection : [[String: AnyObject]] = try json.get("content_collection")
        
        var resources = [Resource]()
        for entry in content_collection {
            do {
                resources.append(Resource(title: try entry.get("title"),
                                          numChildren: try entry.get("numChildren"),
                                          type: try entry.get("type"),
                                          url: try entry.get("url"),
                                          webUrl: try entry.get("webLinkUrl")))
            } catch {
                print(error)
            }
        }
        return resources
    }
    
    static func getResources(for collection: CourseCollection) async throws -> [Resource] {
        print("Loading resources for collection \(collection.collectionName)")
        
        var allResources = [Resource]()
        try await withThrowingTaskGroup(of: [Resource].self) { taskGroup in
            for course in collection.courses {
                taskGroup.addTask {
                    try await getResources(forSiteId: course.siteId)
                }
                for try await result in taskGroup {
                    print("├── Loaded \(result.count) resources for course \(course.name)")
                    allResources.append(contentsOf: result)
                }
            }
        }
        
        print("Loaded all \(allResources.count) resources for collection \(collection.collectionName)")
        return buildHierarchy(allResources)
    }
    
    private static func buildHierarchy(_ arry: [Resource]) -> [Resource] {
        var roots = [Resource]()
        var children = [String:[Resource]]()
        
        // find the top level nodes and hash the children based on parent
        for res in arry {
            let parent = res.treeIds.parent
            if parent == "" {
                roots.append(res)
            } else if children[parent] != nil {
                children[parent]!.append(res)
            } else {
                children[parent] = [res]
            }
        }
        
        // function to recursively build the tree
        func findChildren(parent: Resource) {
            let ids = parent.treeIds
            if (children[ids.id] != nil) {
                parent.children = children[ids.id];
                for child in parent.children! {
                    findChildren(parent: child)
                }
            }
        }
        // enumerate through to handle the case where there are multiple roots
        for root in roots {
            findChildren(parent: root)
        }
        
        if roots.count == 1, roots[0].type == "collection", let children = roots[0].children {
            return children
        } else { return roots }
    }
}


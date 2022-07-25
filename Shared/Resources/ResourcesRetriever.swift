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
    var parent : Resource?
    var children : [Resource]?
    
    var icon: String {
        if children == nil {
            return "doc"
        } else if children!.isEmpty {
            return "folder"
        } else {
            return "folder.fill"
        }
    }
    
    init(_ tuple: (title: String, numChildren: Int, type: String, url: String)) {
        self.numChildren = tuple.numChildren
        self.title = tuple.title
        self.type = tuple.type
        self.url = tuple.url
        
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
    static func getResources(for collection: CourseCollection, build: Bool = true, completion: @escaping ([Resource]?) -> Void) {
        Networking.getJSONArrayAt("content", from: collection.courses, aggregatingBy: "content_collection") { jsonArray in
            var resources = [Resource]()
            
            for resource in jsonArray {
                guard let numChildren = resource["numChildren"] as? Int,
                      let type = resource["type"] as? String,
                      let title = resource["title"] as? String,
                      let url = resource["url"] as? String else {
                    print("A RESOURCE WAS NIL!")
                    continue }
                resources.append(Resource((title, numChildren, type, url)))
            }
            if build {
                completion(buildHierarchy(resources))
            } else {
                completion(resources)
            }
            
            
        }
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

class ResourceViewModel: LoadableObject {
    @Published private(set) var state: LoadingState<[Resource]> = .idle
    
    let collection: CourseCollection
    
    init(_ collection: CourseCollection) {
        self.collection = collection
    }
    
    func load() {
        state = .loading
        print("requested to load")
        ResourceRetriever.getResources(for: collection, build: true) { resources in
            if resources == nil {
                self.state = .failed("It was nil")
            } else {
                self.state = .loaded(resources!)
            }
        }
    }
}


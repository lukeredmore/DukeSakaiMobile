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
    static func getResources(forSiteId siteId: String, completion: @escaping ([Resource]?) -> Void) {
        let URLinfo = getInitialItems(siteId: siteId, endpoint: "content")
        let urlRequest = URLinfo.urlRequest
        let session = URLinfo.session
        
        
        
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as? HTTPURLResponse
            if (httpResponse == nil) {
                completion(nil)
                return
            }
            
            do {
                if httpResponse?.statusCode == 200,
                   let fullJson = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: AnyObject],
                   let json = fullJson["content_collection"] as? [[String: AnyObject]] {
                    var resources : [Resource] = []
                    for resource in json {
                        guard let numChildren = resource["numChildren"] as? Int,
                              let type = resource["type"] as? String,
                              let title = resource["title"] as? String,
                              let url = resource["url"] as? String else {
                            print("A RESOURCE WAS NIL!")
                            continue }
                        resources.append(Resource((title, numChildren, type, url)))
                    }
                    completion(buildHierarchy(resources))
                }
            } catch {
                print("Error with Json: \(error)")
                completion(nil)
            }
        }
        task.resume()
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



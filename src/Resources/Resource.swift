//
//  Resource.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import Foundation

class Resource: Identifiable, Equatable {
    static func == (lhs: Resource, rhs: Resource) -> Bool {
        lhs.url == rhs.url
    }
    
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
}

class ResourceRetriever {
    static func getResource(fromResourceUrl url: URL?) -> Resource? {
        guard let url = url,
              let path = URLComponents(url: url, resolvingAgainstBaseURL: false)?.path,
              path.hasPrefix("/access/content/attachment/") == true,
              let last = path.split(separator: "/").last else { return nil }
        let filename = String(last)
        let fileExtension = String(filename.split(separator: ".").last!)
        var type = "unknown"
        
        switch fileExtension {
        case "jpg", "jpeg", "png":
            type = "image"
        case "docx", "doc":
            type = "officedocument"
        case "pdf":
            type = "pdf"
        default: break
        }
        return Resource(title: filename, numChildren: 0, type: type, url: url.absoluteString)
    }
}

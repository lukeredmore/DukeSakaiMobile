//
//  DocumentRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import Foundation

class DocumentRetriever {
    static func getFromURL(_ urlString: String, title: String, completion: @escaping (URL?) -> Void) {
        let url = URL(string: urlString)!
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            // TODO: check for and handle errors:
            // * errorOrNil should be nil
            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
            guard let fileURL = urlOrNil else { return }
                do {
                    let documentsURL = try
                        FileManager.default.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
                    let savedURL = documentsURL.appendingPathComponent(title)
                    let _ = try FileManager.default.replaceItemAt(savedURL, withItemAt: fileURL)
                    completion(savedURL)
                } catch {
                    print ("file error: \(error)")
                    completion(nil)
                }
        }
        downloadTask.resume()
    }
    
    static func removeDocAt(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
}

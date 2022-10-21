//
//  ImportedFile.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/23/22.
//

import UIKit
import QuickLookThumbnailing

public class ImportedFile: Identifiable, Equatable {
    public static func == (lhs: ImportedFile, rhs: ImportedFile) -> Bool {
        lhs.uti == rhs.uti && lhs.name == rhs.name && lhs.path == rhs.path
    }
    
    public var name: String
    public var path: URL
    public var uti: UTI
    public static let THUMBNAIL_SIZE = 75.0
    
    public init(name: String, path: URL, uti: UTI) {
        self.name = name
        self.path = path
        self.uti = uti
    }
    
    public func getThumbnail(completion: @escaping (UIImage) -> Void) {
        if uti.preferredMIMEType?.contains("image") == true {
            let data = try! Data(contentsOf: path)
            completion(UIImage(data: data)!)
            return
        }
        let request = QLThumbnailGenerator.Request(
            fileAt: path,
            size: CGSize(width: ImportedFile.THUMBNAIL_SIZE, height: ImportedFile.THUMBNAIL_SIZE),
            scale: UIScreen.main.scale,
            representationTypes: [.lowQualityThumbnail, .thumbnail])
        QLThumbnailGenerator.shared.generateRepresentations(for: request) { image, _, error in
            if let image = image {
                completion(image.uiImage)
            } else if let error = error {
                print(error)
                completion(UIImage(named: "default-thumbnail")!)
            }
        }
    }
}

//
//  FileImportHelper.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import Foundation
import PDFKit
import Photos
import VisionKit

public enum PhotoFileFormat: Int, CaseIterable {//}, PersistableEnum {
    case jpg, heic, png
    
    public var title: String {
        switch self {
        case .jpg:
            return "JPG"
        case .heic:
            return "HEIC"
        case .png:
            return "PNG"
        }
    }
    
    public var selectionTitle: String {
        switch self {
        case .jpg:
            return "JPG"// \(KDriveResourcesStrings.Localizable.savePhotoJpegDetail)"
        case .heic:
            return "HEIC"
        case .png:
            return "PNG"
        }
    }
    
    public var uti: UTI {
        switch self {
        case .jpg:
            return .jpeg
        case .heic:
            return .heic
        case .png:
            return .png
        }
    }
    
    public var `extension`: String {
        return uti.preferredFilenameExtension!
    }
}

public class FileImportHelper {
    public static let instance = FileImportHelper()
    
    private let imageCompression = 0.8
    
    // MARK: - Public methods
    
    public func importItems(_ itemProviders: [NSItemProvider],
                            userPreferredPhotoFormat: PhotoFileFormat? = nil,
                            completion: @escaping ([ImportedFile], Int) -> Void) -> Progress {
        let perItemUnitCount: Int64 = 10
        let progress = Progress(totalUnitCount: Int64(itemProviders.count) * perItemUnitCount)
        let dispatchGroup = DispatchGroup()
        var items = [ImportedFile]()
        var errorCount = 0
        
        for itemProvider in itemProviders {
            dispatchGroup.enter()
            if itemProvider.hasItemConformingToTypeIdentifier(UTI.url.identifier) && itemProvider.registeredTypeIdentifiers.count == 1 {
                let childProgress = getURL(from: itemProvider) { [weak self] result in
                    self?.handleLoadObjectResult(result, for: itemProvider,
                                                 uti: .internetShortcut,
                                                 extension: "webloc",
                                                 importedItems: &items,
                                                 errorCount: &errorCount)
                    dispatchGroup.leave()
                }
                progress.addChild(childProgress, withPendingUnitCount: perItemUnitCount)
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTI.plainText.identifier)
                        && !itemProvider.hasItemConformingToTypeIdentifier(UTI.fileURL.identifier)
                        && itemProvider.canLoadObject(ofClass: String.self) {
                let childProgress = getTextFile(from: itemProvider, typeIdentifier: UTI.plainText.identifier) { [weak self] result in
                    self?.handleLoadObjectResult(result, for: itemProvider,
                                                 uti: .plainText,
                                                 extension: UTI.plainText.preferredFilenameExtension ?? "txt",
                                                 importedItems: &items,
                                                 errorCount: &errorCount)
                    dispatchGroup.leave()
                }
                progress.addChild(childProgress, withPendingUnitCount: perItemUnitCount)
            } else if itemProvider.registeredTypeIdentifiers.count == 1 &&
                        itemProvider.registeredTypeIdentifiers.first == UTI.image.identifier {
                let childProgress = getImage(from: itemProvider) { [weak self] result in
                    self?.handleLoadObjectResult(result, for: itemProvider,
                                                 uti: .image,
                                                 extension: "png",
                                                 importedItems: &items,
                                                 errorCount: &errorCount)
                    dispatchGroup.leave()
                }
                progress.addChild(childProgress, withPendingUnitCount: perItemUnitCount)
            } else if let typeIdentifier = getPreferredTypeIdentifier(for: itemProvider,
                                                                      userPreferredPhotoFormat: userPreferredPhotoFormat) {
                let childProgress = getFile(from: itemProvider, typeIdentifier: typeIdentifier) { result in
                    switch result {
                    case .success((let filename, let fileURL)):
                        items.append(ImportedFile(name: filename, path: fileURL, uti: UTI(typeIdentifier) ?? .data))
                    case .failure(let error):
                        print("Error while getting file: \(error)")
                        errorCount += 1
                    }
                    dispatchGroup.leave()
                }
                progress.addChild(childProgress, withPendingUnitCount: perItemUnitCount)
            } else {
                // For some reason registeredTypeIdentifiers is empty (shouldn't occur)
                progress.completedUnitCount += perItemUnitCount
                errorCount += 1
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(items, errorCount)
        }
        
        return progress
    }
    
    /* Unused imports
     public func upload(files: [ImportedFile], in directory: File, drive: Drive) throws {
     guard directory.capabilities.canUpload else {
     throw ImportError.accessDenied
     }
     
     for file in files {
     let uploadFile = UploadFile(
     parentDirectoryId: directory.id,
     userId: drive.userId,
     driveId: drive.id,
     url: file.path,
     name: file.name
     )
     UploadQueue.instance.addToQueue(file: uploadFile)
     }
     }
     
     public func upload(photo: UIImage, name: String, format: PhotoFileFormat, in directory: File, drive: Drive) throws {
     guard directory.capabilities.canUpload else {
     throw ImportError.accessDenied
     }
     
     let name = name.addingExtension(format.extension)
     let data: Data?
     switch format {
     case .jpg:
     data = photo.jpegData(compressionQuality: imageCompression)
     case .heic:
     data = photo.heicData(compressionQuality: imageCompression)
     case .png:
     var photo = photo
     if photo.imageOrientation != .up {
     let format = photo.imageRendererFormat
     photo = UIGraphicsImageRenderer(size: photo.size, format: format).image { _ in
     photo.draw(at: .zero)
     }
     }
     data = photo.pngData()
     }
     guard let data = data else {
     throw ImportError.emptyImageData
     }
     try upload(data: data, name: name, uti: format.uti, drive: drive, directory: directory)
     }
     
     public func upload(videoUrl: URL, name: String, in directory: File, drive: Drive) throws {
     guard directory.capabilities.canUpload else {
     throw ImportError.accessDenied
     }
     
     let uti = UTI.quickTimeMovie
     let name = name.addingExtension(uti.preferredFilenameExtension ?? "mov")
     let data = try Data(contentsOf: videoUrl)
     try upload(data: data, name: name, uti: uti, drive: drive, directory: directory)
     }
     
     public func upload(scan: VNDocumentCameraScan, name: String, scanType: ScanFileFormat, in directory: File, drive: Drive) throws {
     if !directory.capabilities.canUpload {
     throw ImportError.accessDenied
     }
     
     let data: Data?
     let name = name.addingExtension(scanType.extension)
     switch scanType {
     case .pdf:
     let pdfDocument = PDFDocument()
     for i in 0 ..< scan.pageCount {
     let pageImage = scan.imageOfPage(at: i)
     // Compress page image before adding it to the PDF
     if let pageData = pageImage.jpegData(compressionQuality: imageCompression),
     let compressedPageImage = UIImage(data: pageData),
     let pdfPage = PDFPage(image: compressedPageImage) {
     pdfDocument.insert(pdfPage, at: i)
     }
     }
     data = pdfDocument.dataRepresentation()
     case .image:
     let image = scan.imageOfPage(at: 0)
     data = image.jpegData(compressionQuality: imageCompression)
     }
     guard let data = data else {
     throw ImportError.emptyImageData
     }
     try upload(data: data, name: name, uti: scanType.uti, drive: drive, directory: directory)
     }
     
     private func upload(data: Data, name: String, uti: UTI, drive: Drive, directory: File) throws {
     let targetURL = generateImportURL(for: uti)
     try data.write(to: targetURL)
     let newFile = UploadFile(
     parentDirectoryId: directory.id,
     userId: drive.userId,
     driveId: drive.id,
     url: targetURL,
     name: name
     )
     UploadQueue.instance.addToQueue(file: newFile)
     }
     
     */
    
    public static func getDefaultFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmssSS"
        return formatter.string(from: Date())
    }
    
    public func generateImportURL(for contentType: UTI?) -> URL {
        let documentsURL = try!
        FileManager.default.url(for: .documentDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: false)
        
        
        var url = documentsURL.appendingPathComponent(UUID().uuidString, isDirectory: false)
        if let uti = contentType {
            url.appendPathExtension(for: uti)
        }
        return url
    }
    
    // MARK: - Private methods
    
    private func handleLoadObjectResult(_ result: Result<URL, Error>,
                                        for itemProvider: NSItemProvider,
                                        uti: UTI,
                                        extension: String,
                                        importedItems: inout [ImportedFile],
                                        errorCount: inout Int) {
        switch result {
        case .success(let fileURL):
            let name = "\(itemProvider.suggestedName ?? FileImportHelper.getDefaultFileName()).\(`extension`)"
            
            importedItems.append(ImportedFile(name: name, path: fileURL, uti: uti))
        case .failure(let error):
            print("Error while getting image: \(error)")
            errorCount += 1
        }
    }
    
    private func getPreferredTypeIdentifier(for itemProvider: NSItemProvider, userPreferredPhotoFormat: PhotoFileFormat?) -> String? {
        if itemProvider.hasItemConformingToTypeIdentifier(UTI.heic.identifier) || itemProvider.hasItemConformingToTypeIdentifier(UTI.jpeg.identifier) {
            if let userPreferredPhotoFormat = userPreferredPhotoFormat,
               itemProvider.hasItemConformingToTypeIdentifier(userPreferredPhotoFormat.uti.identifier) {
                return userPreferredPhotoFormat.uti.identifier
            }
            return itemProvider.hasItemConformingToTypeIdentifier(UTI.heic.identifier) ? UTI.heic.identifier : UTI.jpeg.identifier
        }
        
        if !itemProvider.hasItemConformingToTypeIdentifier(UTI.directory.identifier) {
            // We cannot upload folders so we ignore them
            return itemProvider.registeredTypeIdentifiers.first
        } else {
            return nil
        }
    }
    
    private func getURL(from itemProvider: NSItemProvider, completion: @escaping (Result<URL, Error>) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: 10)
        let childProgress = itemProvider.loadObject(ofClass: URL.self) { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                // Save the URL as a webloc file (plist)
                let content = ["URL": url.absoluteString]
                let targetURL = self.generateImportURL(for: nil).appendingPathExtension("webloc")
                do {
                    let encoder = PropertyListEncoder()
                    let data = try encoder.encode(content)
                    try data.write(to: targetURL)
                    completion(.success(targetURL))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(SakaiError.importError))
            }
            progress.completedUnitCount += 2
        }
        progress.addChild(childProgress, withPendingUnitCount: 8)
        return progress
    }
    
    private func getTextFile(from itemProvider: NSItemProvider, typeIdentifier: String, completion: @escaping (Result<URL, Error>) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: 1)
        itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { coding, error in
            if let error = error {
                completion(.failure(error))
            } else if let text = coding as? String {
                let targetURL = self.generateImportURL(for: UTI(typeIdentifier))
                do {
                    try text.write(to: targetURL, atomically: true, encoding: .utf8)
                    completion(.success(targetURL))
                } catch {
                    completion(.failure(error))
                }
            } else if let data = coding as? Data {
                let targetURL = self.generateImportURL(for: UTI(typeIdentifier))
                do {
                    try data.write(to: targetURL)
                    completion(.success(targetURL))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(SakaiError.importError))
            }
            progress.completedUnitCount = 1
        }
        return progress
    }
    
    private func getFile(from itemProvider: NSItemProvider, typeIdentifier: String, completion: @escaping (Result<(String, URL), Error>) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: 10)
        let childProgress = itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                let targetURL = self.generateImportURL(for: UTI(typeIdentifier))
                do {
                    try FileManager.default.copyOrReplace(sourceUrl: url, destinationUrl: targetURL)
                    completion(.success((url.lastPathComponent, targetURL)))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(SakaiError.importError))
            }
            progress.completedUnitCount += 2
        }
        progress.addChild(childProgress, withPendingUnitCount: 8)
        return progress
    }
    
    private func getImage(from itemProvider: NSItemProvider, completion: @escaping (Result<URL, Error>) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: 1)
        itemProvider.loadItem(forTypeIdentifier: UTI.image.identifier) { coding, error in
            autoreleasepool {
                if let error = error {
                    completion(.failure(error))
                } else {
                    let targetURL = self.generateImportURL(for: UTI.png)
                    
                    if let image = coding as? UIImage,
                       let data = image.pngData() {
                        do {
                            try data.write(to: targetURL)
                            completion(.success(targetURL))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(SakaiError.importError))
                    }
                }
                progress.completedUnitCount = 1
            }
        }
        return progress
    }
}

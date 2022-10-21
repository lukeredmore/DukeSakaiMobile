//
//  ImportEnvironment.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/23/22.
//

import UIKit

class ImportEnvironment: ObservableObject {
    @Published var files: [ImportedFile]? = nil
    @Published var scene: UIWindowScene? = nil
    @Published var headerHeight: CGFloat = 0.0
    @Published var cancel: () -> Void = {}
    @Published var showAlert: (_ msg: String) -> Void = { _ in }
    
    static let empty = ImportEnvironment()
}

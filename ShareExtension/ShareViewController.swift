//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/21/22.
//

import UIKit
import SwiftUI

class ImportEnvironment: ObservableObject {
    @Published var files: [ImportedFile]? = nil
    @Published var scene: UIWindowScene? = nil
}

class ShareViewController: UIHostingController<AnyView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()

        print("View loading")
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            print("No items found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
                           
        let _ = FileImportHelper.instance.importItems(itemProviders, userPreferredPhotoFormat: .jpg) { files, errorCount in
            print("There were \(errorCount) errors importing these \(itemProviders.count) files")
            self.setEnvironmentFiles(files)
        }
    }
    
    private func setEnvironmentFiles(_ files : [ImportedFile]) {
        DispatchQueue.main.async {
            guard let nav = self.navigationController as? ShareNavigationConroller else {
                print("Could not find navigation controller")
                return
            }
            nav.env.scene = self.view.window!.windowScene
            nav.env.files = files
        }
    }
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "DukeNavy")
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "DukeNavy")
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.title = "Sakai Assignments"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(itemCancel, animated: false)
    }
    
    @objc private func cancelAction () {
        let error = NSError(domain: "com.lukeredmore.DukeSakai", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sakai upload action cancelled"])
        extensionContext?.cancelRequest(withError: error)
    }
    
    private func presentFailureAlert() {
        let alert = UIAlertController(title: "Upload failed", message: "These colors were not uploaded. Please check the logs.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default) { _ in
            self.extensionContext?.completeRequest(returningItems: [])
        })
        self.present(alert, animated: true)
    }
    
    private func presentSuccessAlert() {
        let alert = UIAlertController(title: "Upload succeeded!", message: "Colors saved sucessfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default) { _ in
            self.extensionContext?.completeRequest(returningItems: [])
        })
        self.present(alert, animated: true)
    }
    
    @objc(ShareNavigationController)
    class ShareNavigationConroller: UINavigationController {
        let env = ImportEnvironment()
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            let swiftUIView = AnyView(AttachFileToAssignmentView().environmentObject(env))
            self.setViewControllers([ShareViewController(rootView: swiftUIView)], animated: false)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}

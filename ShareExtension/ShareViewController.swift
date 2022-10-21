//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/21/22.
//

import SwiftUI

@objc(ShareViewController)
class ShareViewController: UIViewController {
    let env = ImportEnvironment.empty
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loading")
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            print("No items found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        let _ = FileImportHelper.instance.importItems(itemProviders, userPreferredPhotoFormat: .jpg) { files, errorCount in
            print("There were \(errorCount) errors importing these \(itemProviders.count) files")
            DispatchQueue.main.async {
                self.env.files = files
                self.env.scene = self.view.window!.windowScene
            }
        }
    }
    
    private func cancelAction () {
        let error = NSError(domain: "com.lukeredmore.DukeSakai", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sakai upload action cancelled"])
        extensionContext?.cancelRequest(withError: error)
    }
    
    override func loadView() {
        super.loadView()
        
        env.cancel = cancelAction
        
        
        let child = UIHostingController(rootView: ShareNavigationView().environmentObject(env))
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = view.bounds
        view.addSubview(child.view)
        addChild(child)
    }
}

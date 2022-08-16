//
//  AuthWebViewController.swift
//  DukeSakai
//
//  Created by Luke Redmore on 8/12/22.
//

import SwiftUI
import WebKit

struct AuthWebView : UIViewControllerRepresentable {
    typealias UIViewControllerType = AuthWebViewController
    let completion: ((accessToken: String, sessionToken: String)?) -> Void
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return AuthWebViewController(completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    class AuthWebViewController: UIViewController, WKNavigationDelegate {
        
        let item = UINavigationItem(title: "")
        let titleLabel = UILabel()
        let webView = WKWebView()
        let navBar = UINavigationBar()
        private let progressView = UIProgressView(progressViewStyle: .bar)
        
        let completion: ((accessToken: String, sessionToken: String)?) -> Void
        
        init(completion: @escaping ((accessToken: String, sessionToken: String)?) -> Void) {
            self.completion = completion
            super.init(nibName: nil, bundle: nil)
        }
        
        @objc func cancel() {
            completion(nil)
        }
        
        @objc func refresh() {
            progressView.setProgress(0.2, animated: true)
            webView.reload()
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" {
                progressView.setProgress(Float(webView.estimatedProgress), animated: true)
                if webView.estimatedProgress == 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.progressView.progress = 0
                    }
                }
            }
        }
        
        private func setTitle(_ str: String) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "lock.fill")?.withTintColor(.label)
            
            let imageOffsetY: CGFloat = -2.0
            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width*0.75, height: imageAttachment.image!.size.height*0.75)
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            
            let completeText = NSMutableAttributedString(string: "")
            completeText.append(attachmentString)
            completeText.append(NSAttributedString(string: " \(str)"))
            
            self.titleLabel.font = .boldSystemFont(ofSize: 16.0)
            self.titleLabel.textAlignment = .center
            self.titleLabel.attributedText = completeText
        }
        
        private func layoutNavBar() {
            navBar.translatesAutoresizingMaskIntoConstraints = false
            navBar.isTranslucent = true
            navBar.isOpaque = false
            
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            
            let refreshButton = UIButton(type: .system)
            let image = UIImage(systemName: "arrow.clockwise")?.withRenderingMode(.alwaysTemplate)
            refreshButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            refreshButton.setImage(image, for: .normal)
            refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
            let refreshBarButton = UIBarButtonItem(customView: refreshButton)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            item.leftBarButtonItem = cancelButton
            item.rightBarButtonItem = refreshBarButton
            item.titleView = titleLabel
            navBar.items = [item]
            
            navBar.addSubview(progressView)
            let bottomConstraint = NSLayoutConstraint(item: navBar, attribute: .bottom, relatedBy: .equal, toItem: progressView, attribute: .bottom, multiplier: 1, constant: 1)
            let leftConstraint = NSLayoutConstraint(item: navBar, attribute: .leading, relatedBy: .equal, toItem: progressView, attribute: .leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: navBar, attribute: .trailing, relatedBy: .equal, toItem: progressView, attribute: .trailing, multiplier: 1, constant: 0)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.progressTintColor = .systemBlue
            view.addConstraints([bottomConstraint, leftConstraint, rightConstraint])
        }
        
        override func loadView() {
            view = UIView()
            
            layoutNavBar()
            
            webView.navigationDelegate = self
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            webView.load(URLRequest(url: URL(string: "https://mobile-authorizer.oit.duke.edu/dukemobile/login")!))
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            webView.scrollView.showsHorizontalScrollIndicator = false

            view.addSubview(navBar)
            NSLayoutConstraint.activate([
                navBar.topAnchor.constraint(equalTo: view.topAnchor),
                navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            webView.scrollView.contentInset.top = navBar.frame.height
            webView.scrollView.contentInset.bottom = navBar.frame.height * -1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            progressView.setProgress(0.2, animated: true)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if let urlStr = navigationAction.request.url?.host {
                setTitle(urlStr)
            }
            
            if let url = navigationAction.request.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               components.path == "/dukemobile/token" {
                if let queryItems = components.queryItems?.reduce(into: [String: String](), { result, item in
                    result[item.name] = item.value
                }),
                   let accessToken = queryItems["access_token"],
                   let sessionToken = queryItems["session_token"] {
                    print("Found tokens")
                    print(accessToken)
                    print(sessionToken)
                    completion((accessToken, sessionToken))
                    return .cancel
                } else {
                    print("Could not find tokens")
                    completion(nil)
                    return .cancel
                }
            }
            return .allow
        }
        
    }
}

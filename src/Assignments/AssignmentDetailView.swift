//
//  AssignmentDetailView.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/19/22.
//

import SwiftUI
import WebKit

struct AssignmentDetailView: View {
    let assignment: Assignment
    
    @State private var resourceToShow : Resource? = nil
    @State private var showingSheet = false
    
    
    var body: some View {
        VStack {
            AssignmentWebView(directUrl: assignment.directUrl, resourceToShow: $resourceToShow)
                .navigationTitle(assignment.title)
                .onChange(of: resourceToShow) { _ in
                    showingSheet = true
                }
            Text("Status: \(assignment.status ?? "nil")")
            Text("Scale: \(assignment.scale ?? "nil")")
            HStack { /* TODO: Dev only (remove in prod) */
                Button("Copy direct URL") {
                    UIPasteboard.general.string = assignment.directUrl.absoluteString
                }
                Button("Copy json URL") {
                    UIPasteboard.general.string = "https://sakai.duke.edu/direct/assignment/item/\(assignment.id).json"
                }
            }
        }.sheet(isPresented: $showingSheet) {
            NavigationView {
                ResourceDetailView(resource: resourceToShow, modalPresentation: true)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(resourceToShow?.title ?? "")
            }
        }
    }
}

struct AssignmentWebView: UIViewRepresentable {
    var cssString: String {
        return """
            body {
                padding: 1em;
                color: \(UIColor.label.hex) !important;
                background-color: \(UIColor.systemBackground.hex) !important;
            }
            .itemSummary th, .itemSummary .row, .textPanel * {
                color: \(UIColor.label.hex) !important;
            }
            a, .textPanel a {
                color: \(UIColor.systemBlue.hex) !important;
            }
            img {
                max-width: 100%;
            }
        """.replacingOccurrences(of: "\n", with: "")
    }
    
    var jsScript: WKUserScript {
        WKUserScript(source: """
        var style = document.createElement('style');
        style.innerHTML = '\(cssString)';
        document.head.appendChild(style);
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        var head = document.getElementsByTagName('head')[0];
        head.appendChild(meta);
        $('.Mrphs-topHeader').remove();
        $('.Mrphs-siteHierarchy').remove();
        $('#toolMenuWrap').remove();
        $('#skipNav').remove();
        $('div.act').has("input[value='Back to list']").remove();
        $("form[name='dummyForm']").has("input[value='Done']").remove();
        $("#submitPanel input[value='Cancel']").remove();
        """,
                     injectionTime: .atDocumentEnd,
                     forMainFrameOnly: false)
    }
    
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.copyCookiesFromURLSession()
        let contentController = WKUserContentController()
        contentController.addUserScript(jsScript)
        config.userContentController = contentController
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.isOpaque = false
        wv.backgroundColor = .systemBackground
        wv.navigationDelegate = context.coordinator
        wv.allowsLinkPreview = false
        wv.allowsBackForwardNavigationGestures = false
        wv.load(URLRequest(url: directUrl))
        return wv
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    typealias UIViewType = WKWebView
    
    let directUrl: URL
    @Binding var resourceToShow: Resource?
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: AssignmentWebView
        
        var initialLoad = true
        
        init(_ parent: AssignmentWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                guard self.initialLoad == true else { print("Already uploaded")
                    return
                }
                self.initialLoad = false
                let path = Bundle.main.path(forResource: "test", ofType: "pdf")!
                let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                webView.populateFileInput(querySelector: "#attachmentspanel input[name='upload']",
                                          data: data,
                                          filename: "test.pdf",
                                          type: "application/pdf")
            }
            
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let resource = ResourceRetriever.getResource(fromResourceUrl: navigationAction.request.url) else {
                return .allow
            }
            print("Found resource")
            if parent.resourceToShow == resource {
                parent.resourceToShow = nil
            }
            parent.resourceToShow = resource
            return .cancel
        }
        
    }
}

//struct AssignmentDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AssignmentDetailView()
//    }
//}

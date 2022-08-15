//
//  ResourceDetailView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct ResourceDetailViewSmall: View {
    @State var downloadLocation : URL? = nil
    @State private var shareSheetPresented = false
    
    let resource: Resource
    
    @ViewBuilder
    private func viewerForFileAt(_ fileURL: URL) -> some View {
        if (resource.type.contains("pdf")) {
            PDFViewer(fileURL)
                .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
                
        } else {
            WebView(urlString: resource.url)
        }
    }
    
    @ViewBuilder
    private var resourceDetailContent: some View {
        if let fileURL = downloadLocation  {
            viewerForFileAt(fileURL)
                .adaptiveSheet(isPresented: $shareSheetPresented,
                               detents: [.medium(), .large()],
                               smallestUndimmedDetentIdentifier: .large) {
                    ShareSheet(activityItems: [fileURL])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.bottom)
                }
                .onTapGesture {
                    shareSheetPresented = false
                }
                .onDisappear {
                    DocumentRetriever.removeDocAt(fileURL)
                    shareSheetPresented = false
                }
        } else {
            ProgressView().onAppear {
                DocumentRetriever.getFromURL(resource.url, title: resource.title) { url in
                    guard let url = url else { print("Error retrieving file"); return }
                    downloadLocation = url
                }
            }
        }
    }
    
    
    var body: some View {
        resourceDetailContent
            .toolbar {
                Button {
                    shareSheetPresented.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(downloadLocation == nil)
            }
    }
}

struct ResourceDetailViewLarge: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let resource: Resource
    
    var body: some View {
        WebView(urlString: resource.url) { presentationMode.wrappedValue.dismiss() }
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    }
}

struct ResourceDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let resource: Resource
        
    @ViewBuilder
    var body: some View {
        if resource.type == "text/url", let webUrl = resource.webUrl {
            SafariView(url: URL(string: webUrl)!) { presentationMode.wrappedValue.dismiss() }
                .navigationBarHidden(true)
                .navigationTitle("")
                .edgesIgnoringSafeArea([.bottom, .leading, .trailing, .top])
        } else if resource.type.contains("pdf") || resource.type.contains("text") || resource.type.contains("officedocument") || resource.type.contains("image")  {
            ResourceDetailViewSmall(resource: resource)
        } else {
            ResourceDetailViewLarge(resource: resource)
        }
    }
}

//struct ResourceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResourceDetailView()
//    }
//}

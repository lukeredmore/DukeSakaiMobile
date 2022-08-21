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
            ResourceWebView(urlString: resource.url)
                .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
                .background(resource.type.contains("officedocument") ? Color.white : Color(uiColor: UIColor.systemBackground))
        }
    }
    
    @ViewBuilder
    private var resourceDetailContent: some View {
        if let fileURL = downloadLocation  {
            viewerForFileAt(fileURL)
                .onTapGesture {
                    shareSheetPresented = false
                }
                .onDisappear {
                    DocumentRetriever.removeDocAt(fileURL)
                    shareSheetPresented = false
                }
                .adaptiveSheet(isPresented: $shareSheetPresented,
                               detents: [.medium(), .large()],
                               smallestUndimmedDetentIdentifier: .large) {
                    ShareSheet(activityItems: [fileURL])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.bottom)
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
                    Image(systemName: "square.and.arrow.up").foregroundColor(.white)
                }
                .disabled(downloadLocation == nil)
            }
    }
}

struct ResourceDetailViewLarge: View {
    //    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let resource: Resource
    
    var body: some View {
        ResourceWebView(urlString: resource.url)// { presentationMode.wrappedValue.dismiss() }
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    }
}

struct ResourceDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let resource: Resource?
    let modalPresentation: Bool
    
    init(resource: Resource?, modalPresentation: Bool = false) {
        self.resource = resource
        self.modalPresentation = modalPresentation
    }
    
    @ViewBuilder
    var decider: some View {
        if let resource = resource, resource.type.contains("pdf")
            || resource.type.contains("text")
            || resource.type.contains("officedocument")
            || resource.type.contains("image") {
            ResourceDetailViewSmall(resource: resource)
        } else if let resource = resource {
            ResourceDetailViewLarge(resource: resource)
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        if modalPresentation {
            decider.toolbar { ToolbarItem(placement: .cancellationAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            } }
        } else {
            decider
        }
    }
}

//struct ResourceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResourceDetailView()
//    }
//}

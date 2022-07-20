//
//  ResourceDetailView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

//public extension UIApplication {
//    func currentUIWindow() -> UIWindow? {
//        let connectedScenes = UIApplication.shared.connectedScenes
//            .filter({
//                $0.activationState == .foregroundActive})
//            .compactMap({$0 as? UIWindowScene})
//
//        let window = connectedScenes.first?
//            .windows
//            .first { $0.isKeyWindow }
//
//        return window
//
//    }
//}

struct ResourceDetailView: View {
    @State var downloadLocation : URL? = nil
    @State private var shareSheetPresented = false
    
    let resource: Resource
    
    @ViewBuilder
    private func viewerForFileAt(_ fileURL: URL) -> some View {
        if (resource.type.contains("pdf")) {
            PDFViewer(fileURL)
                .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
                
        } else {
            Text(resource.title)
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

//struct ResourceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResourceDetailView()
//    }
//}

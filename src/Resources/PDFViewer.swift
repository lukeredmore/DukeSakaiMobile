//
//  PDFViewer.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import PDFKit
import SwiftUI

struct PDFViewer: UIViewRepresentable {
    typealias UIViewType = PDFView
    
    let doc: PDFDocument
    let singlePage: Bool
    
    init(_ docURL: URL, singlePage: Bool = false) {
        self.doc = PDFDocument(url: docURL)!
        self.singlePage = singlePage
    }
    
    func makeUIView(context _: UIViewRepresentableContext<PDFViewer>) -> UIViewType {
        let pdfView = PDFView(frame: UIScreen.main.bounds)
        pdfView.document = doc
        pdfView.autoScales = true
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        if singlePage {
            pdfView.displayMode = .singlePage
        }
        return pdfView
    }
    
    func updateUIView(_ pdfView: UIViewType, context _: UIViewRepresentableContext<PDFViewer>) {
        pdfView.document = doc
    }
}

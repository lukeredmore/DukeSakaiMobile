//
//  FilePreview.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/22/22.
//

import SwiftUI

struct FilePreview: View {
    @State private var thumbnail: Image?
    
    let file: ImportedFile?
    let count: Int?
    
    init(files: [ImportedFile]) {
        if files.count > 1 {
            self.count = files.count
            self.file = nil
        } else {
            self.file = files[0]
            self.count = nil
        }
    }
    
    var body: some View {
        HStack {
            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: ImportedFile.THUMBNAIL_SIZE, height: ImportedFile.THUMBNAIL_SIZE)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: ImportedFile.THUMBNAIL_SIZE, height: ImportedFile.THUMBNAIL_SIZE)
            }
            Text(file?.name ?? "\(count!) files")
        }
        .frame(height: ImportedFile.THUMBNAIL_SIZE)
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing, .bottom])
        .foregroundColor(.white)
        .background(Color("DukeNavy"))
        .onAppear {
            if let file = file {
                file.getThumbnail { image in
                    thumbnail = Image(uiImage: image)
                }
            } else {
                thumbnail = Image("multiple-files")
            }
        }
    }
}

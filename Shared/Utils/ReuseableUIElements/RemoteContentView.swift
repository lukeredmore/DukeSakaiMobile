//
//  RemoteContentViewer.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI
import AsyncView

struct RemoteContentView<Item: Any, Content: View>: View {
    @Binding var selectedCollection: CourseCollection
    @StateObject var model: AsyncModel<Item>
  
    let builder: (_ item: Item) -> Content
    
    
    init(selectedCollection: Binding<CourseCollection>,
         loader: @escaping (_ collection: CourseCollection) async throws -> Item,
         @ViewBuilder builder: @escaping (_ item: Item) -> Content) {
        self._selectedCollection = selectedCollection
        self._model = StateObject(wrappedValue: AsyncModel { try await loader(selectedCollection.wrappedValue) })
        self.builder = builder
    }
    
    
    var body: some View {
        AsyncModelView(model: model, content: builder)
            .onChange(of: selectedCollection) { selco in
                print("Selected resource collection changed, reloading models")
                Task {
                    await model.load()
                }
            }
    }
}

//
//  RemoteContentView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/24/22.
//

import SwiftUI

enum LoadingState<Value> {
    case idle
    case loading
    case failed(String)
    case loaded(Value)
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

struct RemoteContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var content: (Source.Output) -> Content

    init(source: Source, @ViewBuilder content: @escaping (Source.Output) -> Content) {
        self.source = source
        self.content = content
    }


    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            ProgressView()
        case .failed(let error):
            Text(error)
            //            ErrorView(error: error, retryHandler: source.load)
        case .loaded(let output):
            content(output)
        }
    }
}

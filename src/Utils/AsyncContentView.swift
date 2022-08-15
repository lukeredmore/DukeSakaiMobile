//
//  MyEnv.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/27/22.
//

import SwiftUI


enum AsyncContentViewState<Item> {
    case idle
    case inProgress
    case success(Item)
    case refreshing(Item)
    case failure(Error)
}

struct AsyncContentView<Item, Content: View>: View {
    @EnvironmentObject var env : SakaiEnvironment
    @State var status = AsyncContentViewState<Item>.idle
    @State var backgrounded = true
    
    var loader: (_ collection: CourseCollection) async throws -> Item
    var content: (_ item: Item) -> Content
    
    @ViewBuilder
    var body: some View {
        decider.onAppear {
            backgrounded = false
        }
        .onDisappear {
            backgrounded = true
        }
    }
    
    @ViewBuilder
    var decider: some View {
        switch status {
        case .idle:
            Text("")
                .onAppear {
                    loadSync()
                }
        case .inProgress:
            ProgressView()
        case .success(let item), .refreshing(let item):
            content(item)
                .refreshable {
                    await refresh(env.selectedCollection)
                }
                .onChange(of: env.selectedCollection) { col in
                    if backgrounded {
                        status = .idle
                    } else {
                        Task { await load(col)}
                    }
                   
                }
        case .failure(let error):
            ErrorView(error: error, reloadAction: loadSync)
        }
    }
    
    private func loadSync() {
        Task { await load(env.selectedCollection) }
    }
    
    private func refresh(_ col: CourseCollection) async {
        let start = Date()

        guard case let .success(oldItem) = status else {
            return
        }
        
        print("Refreshing \(Item.self) for \(col.collectionName)")
        status = .refreshing(oldItem)
        
        do {
            let ops = try await self.loader(col)
            
            // Artifically slow down refresh so it looks functional
            if start.timeIntervalSinceNow < 0.5 {
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            status = .success(ops)
        } catch {
            status = .failure(error)
        }
    }
    
    private func load(_ col: CourseCollection) async {
        switch status {
        case .inProgress, .refreshing:
            return
        default:
            print("Loading \(Item.self) for \(col.collectionName)")
            status = .inProgress
            
            do {
                status = .success(try await self.loader(col))
            } catch {
                status = .failure(error)
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    let reloadAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            Text(error.localizedDescription)
            if let reloadAction = reloadAction {
                Button(
                    action: {
                        print("Reloading")
                        reloadAction()
                    },
                    label: {
                        Image(systemName: "arrow.clockwise")
                    }
                )
            }
        }
    }
}

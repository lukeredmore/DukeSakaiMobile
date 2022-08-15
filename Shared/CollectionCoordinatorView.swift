//
//  CollectionCoordinatorView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/25/22.
//

import SwiftUI

struct CollectionCoordinatorView: View {
    @StateObject var env = SakaiEnvironment()
    @State private var collectionPickerShown = false
    
    let courseIds: [String]
    
    var toolbarButton: some View {
        Button {
            collectionPickerShown.toggle()
        } label: {
            Text(env.selectedCollection.collectionName == "Favorites" ? "Favorite Courses" : env.selectedCollection.collectionName)
                .font(.headline)
                .fixedSize(horizontal: true, vertical: false)
                .offset(x: 4.0, y: 0.0)
                .foregroundColor(Color.primary)
            
            Image(systemName: "chevron.down")
                .scaleEffect(0.9)
                .offset(x: -3.0, y: 0.0)
                .rotationEffect(.degrees(collectionPickerShown ? -180 : 0), anchor: UnitPoint(x: 0.4, y: 0.5))
                .animation(.spring(), value: collectionPickerShown)
                .foregroundColor(Color.primary)
        }
    }
    
    var body: some View {
        if env.termCollections.isEmpty {
            ProgressView().onAppear { Task {
                await env.createInitialEnv(courseIds: courseIds)
                print("Created Environment, showing home screen")
            }}
        } else {
            NavigationView {
                HomeTabView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .principal) { toolbarButton } }
            }
            .popupMenu(isPresented: $collectionPickerShown) {
                CollectionPickerView() { collectionPickerShown = false }
            }
            .environmentObject(env)
        }
        
    }
}

//struct CollectionCoordinatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        CollectionCoordinatorView(.constant(PreviewUtils.courseList))
//    }
//}

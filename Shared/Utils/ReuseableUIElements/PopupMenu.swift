//
//  PopupMenu.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct PopupMenu<MenuContent: View>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let menuContent: MenuContent
    @Binding var isPresented: Bool
    @State private var scale = 0.0
    @State private var orientation = UIDevice.current.orientation
    
    private let regularPadding: CGFloat = 8.0
    private let regularCorner: CGFloat = 10.0
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> MenuContent) {
        _isPresented = isPresented
        menuContent = content()        
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                ZStack {
                    // Background overlay
                    Color(.sRGB, white: 0, opacity: 0.002)//scale == 0 ? 0.0 : 0.2)
                        .onTapGesture {
                            isPresented = false
                        }
                        .animation(.spring(), value: scale)
                    GeometryReader { geo in
                       
                        VStack {
                            menuContent
                                .cornerRadius(regularCorner)
                                .background(RoundedRectangle(cornerRadius: regularCorner)
                                    .foregroundColor( colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                                            
                                    .shadow(color: .gray.opacity(colorScheme == .dark ? 0 : 0.3), radius: 4, x: 0, y: 6)
                                )
                                .offset(y: scale == 0 ? -200.0 : 0)
                                .scaleEffect(scale)
                                .frame(maxWidth: geo.size.width*0.65, maxHeight: geo.size.height*0.6)
                                .frame(width: geo.size.width)
                                .animation(.interpolatingSpring(stiffness: 180, damping: 17), value: scale)
                            Spacer()
                        }.padding(.top, 3)
                    }
                }
                .offset(y: orientation.isLandscape ? 26 : 44)
                .onRotate { oren in
                    self.orientation = oren
                }
                .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
                .onAppear {
                    orientation = UIDevice.current.orientation
                    scale = 1.0
                }.onDisappear {
                    scale = 0.0
                }
            }
        }
    }
}

extension View {
    func popupMenu<MenuContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> MenuContent) -> some View {
        return self.modifier(PopupMenu(isPresented: isPresented, content: content))
    }
}

struct PopupMenu_Previews: PreviewProvider {
    static let cols = PreviewUtils.allCollections
    static var previews: some View {
        NavigationView  {
            TabView {
                Text("Default").tabItem { Image(systemName: "star") }
            }
            .popupMenu(isPresented: .constant(true)) {
                CollectionPickerView(collections: cols, selectedCollection: .constant(cols[0]))
            }
            .navigationTitle("Test content")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .previewInterfaceOrientation(.portrait)
    }
}

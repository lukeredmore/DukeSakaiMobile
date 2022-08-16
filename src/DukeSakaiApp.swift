//
//  DukeSakaiApp.swift
//  Shared
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

@main
struct DukeSakaiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AuthDecider()
        }
    }
}

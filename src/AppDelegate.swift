//
//  AppDelegate.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/16/22.
//

import UIKit
import BackgroundTasks

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("Scene in background")
        AppDelegate.scheduleSessionRefresh()
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
      ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self // 👈🏻
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.lukeredmore.DukeSakai.sessionrefresh", using: nil) { task in
            Task { await self.handleSessionRefresh(task: task as! BGAppRefreshTask) }
        }
        
        return true
    }
    
    
    static func scheduleSessionRefresh() {
        print("Scheduling session refresh")
        let request = BGAppRefreshTaskRequest(identifier: "com.lukeredmore.DukeSakai.sessionrefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15*60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule session refresh: \(error)")
        }
    }
    
    private func handleSessionRefresh(task: BGAppRefreshTask) async {
        AppDelegate.scheduleSessionRefresh()
        
        print("Started to perform fetch with new api")
        let time = Date().timeIntervalSince1970.magnitude
        var timeArray = UserDefaults.shared.value(forKey: "refresh-times") as? [Double] ?? [Double]()
        timeArray.append(time)
        UserDefaults.shared.set(timeArray, forKey: "refresh-times")
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        if let _ = await Authenticator.validateSakaiSession() {
            UserDefaults.shared.set("Succeeded in validate new", forKey: "refresh-times-\(time)")
            print("Valid session in validate")
            task.setTaskCompleted(success: true)
        } else if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let _ = try? await Authenticator.restoreSession(scene: scene) {
            UserDefaults.shared.set("Succeeded in restore new", forKey: "refresh-times-\(time)")
            print("Valid session in restore")
            task.setTaskCompleted(success: true)
        } else {
            UserDefaults.shared.set("Failed new", forKey: "refresh-times-\(time)")
            print("Invalid session")
            task.setTaskCompleted(success: false)
        }
    }
}

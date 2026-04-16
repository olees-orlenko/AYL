//
//  AYLApp.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct AYLApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var scenePhase = ScenePhase.active
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.scenePhase, scenePhase)
        }
    }
}

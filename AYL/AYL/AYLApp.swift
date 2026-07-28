//
//  AYLApp.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        return true
    }
}

@main
struct AYLApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var scenePhase = ScenePhase.active
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.scenePhase, scenePhase)
                .environmentObject(authManager)
        }
    }
}

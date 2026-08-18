//
//  AYLApp.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        PushNotificationManager.shared.configure()
        PushNotificationManager.shared.requestAuthorizationAndRegister()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push: не удалось зарегистрироваться в APNs — \(error.localizedDescription)")
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

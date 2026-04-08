//
//  AYLApp.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI

@main
struct AYLApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var scenePhase = ScenePhase.active
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.scenePhase, scenePhase)
        }
    }
}

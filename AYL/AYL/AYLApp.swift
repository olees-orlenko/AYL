//
//  AYLApp.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI

@main
struct AYLApp: App {
    @State private var scenePhase = ScenePhase.active
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.scenePhase, scenePhase)
        }
    }
}

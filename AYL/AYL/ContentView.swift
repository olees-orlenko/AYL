//
//  ContentView.swift
//  AYL
//
//  Created by Олеся Орленко on 26.03.2026.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        if scenePhase == .active {
            TabBarView()
        } else {
            Color.clear
        }
    }
}

#Preview {
    ContentView()
}

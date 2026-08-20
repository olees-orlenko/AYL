//
//  TabBarView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.04.2026.
//

import SwiftUI

// MARK: - TabBarView

struct TabBarView: View {
    @ObservedObject private var coordinator = NavigationCoordinator.shared
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            MainView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
                .tag(0)
            GalleryView()
                .tabItem {
                    Label("Галерея", systemImage: "photo.on.rectangle.fill")
                }
                .tag(1)
            NewsView()
                .tabItem {
                    Label("Новости", systemImage: "newspaper.fill")
                }
                .tag(2)
            StaffView()
                .tabItem {
                    Label("Штат", systemImage: "person.3.fill")
                }
                .tag(3)
            ContactsView()
                .tabItem {
                    Label("Контакты", systemImage: "mappin.and.ellipse")
                }
                .tag(4)
        }
        .tint(.lightBlue)
    }
}

// MARK: - Preview

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

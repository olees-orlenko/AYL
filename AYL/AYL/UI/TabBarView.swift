//
//  TabBarView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.04.2026.
//

import SwiftUI

// MARK: - TabBarView

struct TabBarView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            GalleryView()
                .tabItem {
                    Label("Галерея", systemImage: "photo.on.rectangle.fill")
                }
            NewsView()
                .tabItem {
                    Label("Новости", systemImage: "newspaper.fill")
                }
            StaffView()
                .tabItem {
                    Label("Штат", systemImage: "person.3.fill")
                }
            ContactsView()
                .tabItem {
                    Label("Контакты", systemImage: "mappin.and.ellipse")
                }
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

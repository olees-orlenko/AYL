//
//  NavigationCoordinator.swift
//  AYL
//
//  Created by Олеся Орленко on 20.08.2026.
//

import Foundation
internal import Combine

final class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()

    @Published var selectedTab: Int = 0
    @Published var pendingNewsId: String? = nil

    private init() {}

    func openNews(id: String) {
        selectedTab = 2
        pendingNewsId = id
    }
}

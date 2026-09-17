//
//  BannedUsersAdminView.swift
//  AYL
//
//  Created by Олеся Орленко on 17.09.2026.
//

import SwiftUI

struct BannedUsersAdminView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = BannedUsersAdminViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.bannedUsers.isEmpty {
                    ProgressView()
                } else if viewModel.bannedUsers.isEmpty {
                    Text("Вы пока никого не заблокировали")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.bannedUsers, id: \.uid) { user in
                            HStack {
                                Text(user.name)
                                Spacer()
                                Button("Разблокировать") {
                                    viewModel.unban(uid: user.uid)
                                }
                                .font(.caption)
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Заблокированные вами")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                if let uid = authManager.currentUserId {
                    viewModel.fetchBannedUsers(adminUid: uid)
                }
            }
        }
    }
}

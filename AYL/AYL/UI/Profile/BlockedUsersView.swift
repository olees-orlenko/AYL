//
//  BlockedUsersView.swift
//  AYL
//
//  Created by Олеся Орленко on 17.09.2026.
//

import SwiftUI
import FirebaseFirestore

struct BlockedUsersView: View {
    
    // MARK: - Properties
    
    let currentUid: String
    @Environment(\.dismiss) var dismiss
    @State private var blockedUsers: [(uid: String, name: String)] = []
    @State private var isLoading = true
    
    private let db = Firestore.firestore()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if blockedUsers.isEmpty {
                    Text("Заблокированных пользователей нет")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(blockedUsers, id: \.uid) { user in
                            HStack {
                                Text(user.name)
                                Spacer()
                                Button("Разблокировать") {
                                    unblock(uid: user.uid)
                                }
                                .font(.caption)
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Заблокированные")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear { load() }
        }
    }
    
    // MARK: - Private methods
    
    private func load() {
        db.collection("participants").document(currentUid).getDocument { snapshot, _ in
            let map = snapshot?.data()?["blockedUsers"] as? [String: String] ?? [:]
            blockedUsers = map.map { (uid: $0.key, name: $0.value) }.sorted { $0.name < $1.name }
            isLoading = false
        }
    }
    
    private func unblock(uid: String) {
        db.collection("participants").document(currentUid)
            .updateData(["blockedUsers.\(uid)": FieldValue.delete()]) { error in
                if error == nil {
                    blockedUsers.removeAll { $0.uid == uid }
                }
            }
    }
}

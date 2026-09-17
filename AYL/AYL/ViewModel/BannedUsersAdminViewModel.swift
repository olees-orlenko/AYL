//
//  BannedUsersAdminViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 17.09.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions
internal import Combine

final class BannedUsersAdminViewModel: ObservableObject {
    
    @Published var bannedUsers: [(uid: String, name: String)] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchBannedUsers(adminUid: String) {
        isLoading = true
        db.collection("participants")
            .whereField("isBanned", isEqualTo: true)
            .whereField("bannedBy", isEqualTo: adminUid)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                guard let documents = snapshot?.documents else {
                    print("BannedUsers: ошибка загрузки — \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.bannedUsers = documents.map { doc in
                    (uid: doc.documentID, name: doc.data()["name"] as? String ?? "Без имени")
                }
            }
    }
    
    func unban(uid: String, completion: @escaping (Bool) -> Void = { _ in }) {
        Functions.functions().httpsCallable("unbanParticipant").call(["uid": uid]) { [weak self] _, error in
            guard let self else { return }
            if let error {
                print("BannedUsers: не удалось разблокировать — \(error.localizedDescription)")
                completion(false)
                return
            }
            self.bannedUsers.removeAll { $0.uid == uid }
            completion(true)
        }
    }
}

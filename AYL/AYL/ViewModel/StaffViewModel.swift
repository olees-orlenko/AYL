//
//  StaffViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class StaffViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var staffMembers = [StaffMember]()
    @Published var isLoading = true
    private var db = Firestore.firestore()

    // MARK: - Data Fetching

    func fetchData() {
        if staffMembers.isEmpty {
            isLoading = true
        }
        db.collection("Staff").getDocuments { [weak self] querySnapshot, error in
            guard let self else { return }
            self.isLoading = false
            guard let documents = querySnapshot?.documents else {
                print("Ошибка: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.staffMembers = documents.compactMap { doc -> StaffMember? in
                let data = doc.data()
                return StaffMember(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "N/A",
                    position: data["position"] as? String ?? "N/A",
                    bio: data["bio"] as? String ?? "N/A",
                    photoName: data["photoName"] as? String ?? "",
                    telegramLink: data["telegramLink"] as? String
                )
            }
        }
    }
    
    // MARK: - Admin Actions (Add/Update/Delete)
    
    func addMember(name: String, position: String, bio: String, photoName: String, telegramLink: String) {
        let newMember: [String: Any] = [
            "name": name,
            "position": position,
            "bio": bio,
            "photoName": photoName,
            "telegramLink": telegramLink
        ]
        db.collection("Staff").addDocument(data: newMember) { [weak self] error in
            if let error = error {
                print("Ошибка добавления: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
    
    func updateMember(id: String, name: String, position: String, bio: String, photoName: String, telegramLink: String) {
        let updatedData: [String: Any] = [
            "name": name,
            "position": position,
            "bio": bio,
            "photoName": photoName,
            "telegramLink": telegramLink
        ]
        db.collection("Staff").document(id).updateData(updatedData) { [weak self] error in
            if let error = error {
                print("Ошибка обновления: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
    
    func deleteMember(id: String) {
        db.collection("Staff").document(id).delete() { [weak self] error in
            if let error = error {
                print("Ошибка удаления: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
}

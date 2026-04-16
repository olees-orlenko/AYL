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
    private var listener: ListenerRegistration?
    
    func fetchData() {
        isLoading = true
        listener?.remove()
        let staffCollection = db.collection("Staff")
        listener = staffCollection.addSnapshotListener { querySnapshot, error in
            defer {
                self.isLoading = false
            }
            guard let documents = querySnapshot?.documents else {
                print("Ошибка загрузки: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.staffMembers = documents.compactMap { doc -> StaffMember? in
                let data = doc.data()
                let name = data["name"] as? String ?? "N/A"
                let position = data["position"] as? String ?? "N/A"
                let bio = data["bio"] as? String ?? "N/A"
                let photoName = data["photoName"] as? String ?? "ayl_logo_1"
                let telegramLink = data["telegramLink"] as? String
                return StaffMember(
                    id: doc.documentID,
                    name: name,
                    position: position,
                    bio: bio,
                    photoName: photoName,
                    telegramLink: telegramLink
                )
            }
        }
    }
    deinit {
        listener?.remove()
    }
}

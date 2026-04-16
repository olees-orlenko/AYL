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
    
    // MARK: - Init
    
    init() {
        let settings = db.settings
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    func fetchData() {
        if staffMembers.isEmpty {
            isLoading = true
        }
        listener?.remove()
        let staffCollection = db.collection("Staff")
        listener = staffCollection.addSnapshotListener { querySnapshot, error in
            if querySnapshot != nil {
                self.isLoading = false
            }
            guard let documents = querySnapshot?.documents else {
                print("Ошибка: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoading = false
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
    deinit {
        listener?.remove()
    }
}

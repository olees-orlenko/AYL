//
//  RegionsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class RegionsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var regions = [RegionContact]()
    @Published var isLoading = true
    private var db = Firestore.firestore()
    
    // MARK: - Data Fetching
    
    func fetchData() {
        if regions.isEmpty {
            isLoading = true
        }
        db.collection("Regions").getDocuments { [weak self] querySnapshot, error in
            guard let self else { return }
            self.isLoading = false
            guard let documents = querySnapshot?.documents else {
                print("Ошибка: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let fetched = documents.compactMap { doc -> RegionContact? in
                let data = doc.data()
                return RegionContact(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "N/A",
                    telegramLink: data["telegramLink"] as? String,
                    vkLink: data["vkLink"] as? String,
                    websiteLink: data["websiteLink"] as? String
                )
            }
            self.regions = fetched.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        }
    }
    
    // MARK: - Admin Actions (Add/Update/Delete)
    
    func addRegion(name: String, telegramLink: String, vkLink: String, websiteLink: String) {
        let newRegion: [String: Any] = [
            "name": name,
            "telegramLink": telegramLink,
            "vkLink": vkLink,
            "websiteLink": websiteLink
        ]
        db.collection("Regions").addDocument(data: newRegion) { [weak self] error in
            if let error = error {
                print("Ошибка добавления региона: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
    
    func updateRegion(id: String, name: String, telegramLink: String, vkLink: String, websiteLink: String) {
        let updatedData: [String: Any] = [
            "name": name,
            "telegramLink": telegramLink,
            "vkLink": vkLink,
            "websiteLink": websiteLink
        ]
        db.collection("Regions").document(id).updateData(updatedData) { [weak self] error in
            if let error = error {
                print("Ошибка обновления региона: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
    
    func deleteRegion(id: String) {
        db.collection("Regions").document(id).delete { [weak self] error in
            if let error = error {
                print("Ошибка удаления региона: \(error.localizedDescription)")
                return
            }
            self?.fetchData()
        }
    }
}

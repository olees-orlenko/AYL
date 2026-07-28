//
//  GalleryViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 17.04.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class GalleryViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var photos = [GalleryItem]()
    @Published var isLoading = true
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Computed Properties
    
    var groupedPhotos: [String: [GalleryItem]] {
        Dictionary(grouping: photos, by: { $0.title })
    }
    var sortedTitles: [String] {
        groupedPhotos.keys.sorted()
    }
    var allPhotosSorted: [GalleryItem] {
        sortedTitles.flatMap { groupedPhotos[$0] ?? [] }
    }
    
    // MARK: - Data Fetching
    
    func fetchData() {
        isLoading = true
        listener?.remove()
        listener = db.collection("Gallery")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                guard let documents = querySnapshot?.documents else { return }
                self.photos = documents.compactMap { doc -> GalleryItem? in
                    let data = doc.data()
                    return GalleryItem(
                        id: doc.documentID,
                        imageName: data["imageName"] as? String ?? "",
                        title: data["title"] as? String ?? "Без названия"
                    )
                }
            }
    }
    
    // MARK: - Admin Actions (Add/Delete)
    
    func addPhoto(title: String, imageName: String) {
        db.collection("Gallery").addDocument(data: [
            "title": title,
            "imageName": imageName,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
    
    func addMultiplePhotos(title: String, imageUrls: [String]) {
        let batch = db.batch()
        for url in imageUrls {
            let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedUrl.isEmpty {
                let docRef = db.collection("Gallery").document()
                batch.setData([
                    "title": title,
                    "imageName": trimmedUrl,
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: docRef)
            }
        }
        batch.commit { error in
            if let error = error {
                print("Ошибка при массовой загрузке: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePhoto(id: String) {
        db.collection("Gallery").document(id).delete()
    }
}

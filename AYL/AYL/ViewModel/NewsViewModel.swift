//
//  NewsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class NewsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var news = [NewsItem]()
    @Published var isLoading = true
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Init
    
    init() {
        fetchData()
    }
    
    // MARK: - Data Fetching
    
    func fetchData() {
        isLoading = true
        listener?.remove()
        listener = db.collection("News")
            .order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error = error {
                    print("Ошибка загрузки новостей: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.news = documents.compactMap { doc -> NewsItem? in
                    let data = doc.data()
                    let timestamp = data["date"] as? Timestamp ?? Timestamp()
                    return NewsItem(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        content: data["content"] as? String ?? "",
                        imageUrl: data["imageUrl"] as? String ?? "",
                        date: timestamp.dateValue(),
                        linkUrl: data["linkUrl"] as? String ?? ""
                    )
                }
            }
    }
    
    // MARK: - Admin Actions (Add/Delete)
    
    func addNews(title: String, content: String, imageUrl: String, linkUrl: String) {
        db.collection("News").addDocument(data: [
            "title": title,
            "content": content,
            "imageUrl": imageUrl,
            "linkUrl": linkUrl,
            "date": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Ошибка при добавлении новости: \(error.localizedDescription)")
            }
        }
    }
    
    func updateNews(id: String, title: String, content: String, imageUrl: String, linkUrl: String) {
        db.collection("News").document(id).updateData([
            "title": title,
            "content": content,
            "imageUrl": imageUrl,
            "linkUrl": linkUrl,
        ]) { error in
            if let error = error {
                print("Ошибка при обновлении новости: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteNews(id: String) {
        db.collection("News").document(id).delete() { error in
            if let error = error {
                print("Ошибка при удалении новости: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

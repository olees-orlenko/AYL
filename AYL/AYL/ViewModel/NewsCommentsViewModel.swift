//
//  NewsCommentsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import Foundation
import FirebaseFirestore
internal import Combine

final class NewsCommentsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var comments: [NewsComment] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMore = true
    @Published var isSending = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 20
    private var cachedAuthorName: String?
    
    // MARK: - Loading (Pagination)
    
    func loadFirstPage(newsId: String) {
        isLoading = true
        hasMore = true
        lastDocument = nil
        db.collection("News").document(newsId).collection("comments")
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                guard let documents = snapshot?.documents else {
                    print("Comments: ошибка загрузки — \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.comments = documents.compactMap { self.mapComment($0) }
                self.lastDocument = documents.last
                self.hasMore = documents.count == self.pageSize
            }
    }
    
    func loadNextPageIfNeeded(currentComment: NewsComment, newsId: String) {
        guard hasMore, !isLoadingMore, !isLoading,
              let index = comments.firstIndex(where: { $0.id == currentComment.id }),
              index >= comments.count - 3,
              let lastDocument else { return }
        isLoadingMore = true
        db.collection("News").document(newsId).collection("comments")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: pageSize)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoadingMore = false
                guard let documents = snapshot?.documents else {
                    print("Comments: ошибка подгрузки — \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.comments.append(contentsOf: documents.compactMap { self.mapComment($0) })
                self.lastDocument = documents.last ?? self.lastDocument
                self.hasMore = documents.count == self.pageSize
            }
    }
    
    private func mapComment(_ doc: QueryDocumentSnapshot) -> NewsComment? {
        let data = doc.data()
        guard let authorUid = data["authorUid"] as? String,
              let authorName = data["authorName"] as? String,
              let text = data["text"] as? String,
              let timestamp = data["createdAt"] as? Timestamp else { return nil }
        return NewsComment(id: doc.documentID, authorUid: authorUid, authorName: authorName, text: text, createdAt: timestamp.dateValue())
    }
    
    // MARK: - Posting
    
    func addComment(newsId: String, authorUid: String, text: String, completion: @escaping (Bool) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(false)
            return
        }
        isSending = true
        errorMessage = ""
        resolveAuthorName(uid: authorUid) { [weak self] name in
            guard let self else { return }
            let data: [String: Any] = [
                "authorUid": authorUid,
                "authorName": name,
                "text": trimmed,
                "createdAt": FieldValue.serverTimestamp()
            ]
            self.db.collection("News").document(newsId).collection("comments").addDocument(data: data) { error in
                self.isSending = false
                if let error {
                    print("Comments: не удалось отправить комментарий — \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self.loadFirstPage(newsId: newsId)
                completion(true)
            }
        }
    }
    
    private func resolveAuthorName(uid: String, completion: @escaping (String) -> Void) {
        if let cachedAuthorName {
            completion(cachedAuthorName)
            return
        }
        db.collection("participants").document(uid).getDocument { [weak self] snapshot, _ in
            let rawName = snapshot?.data()?["name"] as? String ?? ""
            let name = rawName.trimmingCharacters(in: .whitespaces).isEmpty ? "Участник" : rawName
            self?.cachedAuthorName = name
            completion(name)
        }
    }
    
    // MARK: - Delete
    
    func deleteComment(_ comment: NewsComment, newsId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("News").document(newsId).collection("comments").document(comment.id)
            .delete { [weak self] error in
                guard let self else { return }
                if let error {
                    print("Comments: не удалось удалить \(comment.id) — \(error.localizedDescription)")
                    completion(false)
                    return
                }
                self.comments.removeAll { $0.id == comment.id }
                completion(true)
            }
    }
    
    // MARK: - Complains
    
    func reportComment(_ comment: NewsComment, newsId: String, reportedByUid: String, completion: @escaping (Bool) -> Void = { _ in }) {
        let data: [String: Any] = [
            "newsId": newsId,
            "commentId": comment.id,
            "commentText": comment.text,
            "commentAuthorUid": comment.authorUid,
            "reportedByUid": reportedByUid,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("CommentReports").addDocument(data: data) { error in
            if let error {
                print("Comments: не удалось отправить жалобу — \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

//
//  CommentReportsAdminViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import FirebaseFirestore
import FirebaseFunctions
public import Combine

final class CommentReportsAdminViewModel: ObservableObject {
    @Published var reports: [CommentReport] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchReports() {
        isLoading = true
        db.collection("CommentReports")
            .order(by: "createdAt", descending: true)
            .limit(to: 100)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                guard let documents = snapshot?.documents else {
                    print("CommentReports: ошибка загрузки — \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.reports = documents.compactMap { doc -> CommentReport? in
                    let data = doc.data()
                    guard let newsId = data["newsId"] as? String,
                          let commentId = data["commentId"] as? String,
                          let commentText = data["commentText"] as? String,
                          let commentAuthorUid = data["commentAuthorUid"] as? String,
                          let reportedByUid = data["reportedByUid"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else { return nil }
                    return CommentReport(id: doc.documentID, newsId: newsId, commentId: commentId, commentText: commentText, commentAuthorUid: commentAuthorUid, reportedByUid: reportedByUid, createdAt: timestamp.dateValue())
                }
            }
    }
    
    func deleteCommentAndDismiss(_ report: CommentReport, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("News").document(report.newsId).collection("comments").document(report.commentId).delete { [weak self] error in
            if let error {
                print("CommentReports: не удалось удалить комментарий — \(error.localizedDescription)")
                completion(false)
                return
            }
            self?.dismissReport(report, completion: completion)
        }
    }
    
    func deleteCommentAndBanAuthor(_ report: CommentReport, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("News").document(report.newsId).collection("comments").document(report.commentId).delete { [weak self] error in
            guard let self else { return }
            if let error {
                print("CommentReports: не удалось удалить комментарий — \(error.localizedDescription)")
                completion(false)
                return
            }
            Functions.functions().httpsCallable("banParticipant").call(["uid": report.commentAuthorUid]) { _, error in
                if let error {
                    print("CommentReports: не удалось заблокировать автора — \(error.localizedDescription)")
                }
                self.dismissReport(report, completion: completion)
            }
        }
    }
    
    func dismissReport(_ report: CommentReport, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("CommentReports").document(report.id).delete { [weak self] error in
            guard let self else { return }
            if let error {
                print("CommentReports: не удалось закрыть жалобу — \(error.localizedDescription)")
                completion(false)
                return
            }
            self.reports.removeAll { $0.id == report.id }
            completion(true)
        }
    }
}

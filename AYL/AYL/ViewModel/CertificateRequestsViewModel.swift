//
//  CertificateRequestsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 09.09.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class CertificateRequestsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private var db = Firestore.firestore()
    
    @Published var pendingRequests = [CertificateRequest]()
    @Published var isLoadingPending = false
    
    private func docId(uid: String, newsId: String) -> String {
        "\(uid)_\(newsId)"
    }
    
    private func parse(_ id: String, _ data: [String: Any]) -> CertificateRequest? {
        guard let participantUid = data["participantUid"] as? String,
              let participantName = data["participantName"] as? String,
              let newsId = data["newsId"] as? String,
              let eventTitle = data["eventTitle"] as? String,
              let timestamp = data["eventDate"] as? Timestamp,
              let statusRaw = data["status"] as? String,
              let status = CertificateStatus(rawValue: statusRaw) else { return nil }
        return CertificateRequest(
            id: id,
            participantUid: participantUid,
            participantName: participantName,
            newsId: newsId,
            eventTitle: eventTitle,
            eventDate: timestamp.dateValue(),
            status: status
        )
    }
    
    // MARK: - Participant
    
    func fetchMyRequest(uid: String, newsId: String, completion: @escaping (CertificateRequest?) -> Void) {
        db.collection("CertificateRequests").document(docId(uid: uid, newsId: newsId)).getDocument { [weak self] snapshot, error in
            guard let self, let data = snapshot?.data(), let request = self.parse(snapshot!.documentID, data) else {
                completion(nil)
                return
            }
            completion(request)
        }
    }
    
    func sendRequest(uid: String, name: String, newsId: String, eventTitle: String, eventDate: Date, completion: @escaping (Bool) -> Void = { _ in }) {
        let data: [String: Any] = [
            "participantUid": uid,
            "participantName": name,
            "newsId": newsId,
            "eventTitle": eventTitle,
            "eventDate": Timestamp(date: eventDate),
            "status": CertificateStatus.pending.rawValue,
            "requestedAt": FieldValue.serverTimestamp()
        ]
        db.collection("CertificateRequests").document(docId(uid: uid, newsId: newsId)).setData(data, merge: true) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Admin
    
    func fetchPendingRequests() {
        isLoadingPending = true
        db.collection("CertificateRequests")
            .whereField("status", isEqualTo: CertificateStatus.pending.rawValue)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoadingPending = false
                guard let documents = snapshot?.documents else { return }
                self.pendingRequests = documents.compactMap { self.parse($0.documentID, $0.data()) }
            }
    }
    
    func approveRequest(id: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("CertificateRequests").document(id).updateData(["status": CertificateStatus.approved.rawValue]) { [weak self] error in
            if let error = error {
                print("Ошибка одобрения сертификата: \(error.localizedDescription)")
            }
            if error == nil { self?.fetchPendingRequests() }
            completion(error == nil)
        }
    }
    
    func declineRequest(id: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("CertificateRequests").document(id).updateData(["status": CertificateStatus.declined.rawValue]) { [weak self] error in
            if let error = error {
                print("Ошибка отклонения сертификата: \(error.localizedDescription)")
            }
            if error == nil { self?.fetchPendingRequests() }
            completion(error == nil)
        }
    }
}

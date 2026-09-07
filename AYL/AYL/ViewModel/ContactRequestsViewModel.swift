//
//  ContactRequestsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class ContactRequestsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var incomingRequests = [ContactRequest]()
    
    private var db = Firestore.firestore()
    private var incomingListener: ListenerRegistration?
    
    // MARK: - Incoming
    
    func observeIncoming(uid: String?) {
        incomingListener?.remove()
        guard let uid else {
            incomingRequests = []
            return
        }
        incomingListener = db.collection("ContactRequests")
            .whereField("toUid", isEqualTo: uid)
            .whereField("status", isEqualTo: ContactRequestStatus.pending.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let documents = snapshot?.documents else {
                    if let error {
                        print("Ошибка загрузки запросов на контакты: \(error.localizedDescription)")
                    }
                    return
                }
                self.incomingRequests = documents.compactMap { Self.parse($0) }
            }
    }
    
    deinit {
        incomingListener?.remove()
    }
    
    // MARK: - Sending Request
    
    func fetchMyRequest(fromUid: String, toUid: String, completion: @escaping (ContactRequest?) -> Void) {
        db.collection("ContactRequests")
            .whereField("fromUid", isEqualTo: fromUid)
            .whereField("toUid", isEqualTo: toUid)
            .getDocuments { snapshot, error in
                if let error {
                    print("Ошибка проверки запроса на контакты: \(error.localizedDescription)")
                }
                let requests = snapshot?.documents.compactMap { Self.parse($0) } ?? []
                completion(requests.last)
            }
    }
    
    func sendRequest(fromUid: String, toUid: String, toName: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("participants").document(fromUid).getDocument { [weak self] snapshot, _ in
            guard let self else { return }
            let fromName = snapshot?.data()?["name"] as? String ?? "Участник"
            let data: [String: Any] = [
                "fromUid": fromUid,
                "fromName": fromName,
                "toUid": toUid,
                "toName": toName,
                "status": ContactRequestStatus.pending.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ]
            self.db.collection("ContactRequests").addDocument(data: data) { error in
                if let error {
                    print("Ошибка отправки запроса на контакты: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    // MARK: - Answer for Request
    
    func approve(_ request: ContactRequest, phone: String, email: String, completion: @escaping (Bool) -> Void = { _ in }) {
        let data: [String: Any] = [
            "status": ContactRequestStatus.approved.rawValue,
            "phone": phone,
            "email": email,
            "respondedAt": FieldValue.serverTimestamp()
        ]
        db.collection("ContactRequests").document(request.id).updateData(data) { error in
            if let error {
                print("Ошибка одобрения запроса: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func decline(_ request: ContactRequest, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("ContactRequests").document(request.id).updateData([
            "status": ContactRequestStatus.declined.rawValue,
            "respondedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error {
                print("Ошибка отклонения запроса: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: - Helpers
    
    private static func parse(_ doc: QueryDocumentSnapshot) -> ContactRequest? {
        let data = doc.data()
        guard let fromUid = data["fromUid"] as? String,
              let fromName = data["fromName"] as? String,
              let toUid = data["toUid"] as? String,
              let toName = data["toName"] as? String,
              let statusRaw = data["status"] as? String,
              let status = ContactRequestStatus(rawValue: statusRaw) else { return nil }
        return ContactRequest(
            id: doc.documentID,
            fromUid: fromUid,
            fromName: fromName,
            toUid: toUid,
            toName: toName,
            status: status,
            phone: data["phone"] as? String,
            email: data["email"] as? String
        )
    }
}

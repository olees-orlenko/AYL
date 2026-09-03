//
//  EventSignupManager.swift
//  AYL
//
//  Created by Олеся Орленко on 03.09.2026.
//

import Foundation
import FirebaseFirestore
internal import Combine

final class EventSignupManager: ObservableObject {
    
    @Published var signedUpNewsIds: Set<String> = []
    @Published var upcomingSignups: [EventSignup] = []
    
    private let db = Firestore.firestore()
    private var currentUid: String?
    private var currentRole: ParticipantRole = .alpha
    
    func load(uid: String?) {
        currentUid = uid
        guard let uid else {
            signedUpNewsIds = []
            upcomingSignups = []
            return
        }
        let participantRef = db.collection("participants").document(uid)
        participantRef.getDocument { [weak self] snapshot, _ in
            guard let self else { return }
            if let roleRaw = snapshot?.data()?["role"] as? String {
                self.currentRole = ParticipantRole(rawValue: roleRaw) ?? .alpha
            }
        }
        participantRef.collection("eventSignups")
            .order(by: "eventDate")
            .getDocuments { [weak self] snapshot, _ in
                guard let self, let documents = snapshot?.documents else { return }
                self.upcomingSignups = documents.compactMap { doc -> EventSignup? in
                    let data = doc.data()
                    guard let title = data["eventTitle"] as? String,
                          let timestamp = data["eventDate"] as? Timestamp,
                          let roleRaw = data["role"] as? String,
                          let role = ParticipantRole(rawValue: roleRaw) else { return nil }
                    return EventSignup(id: doc.documentID, newsId: doc.documentID, eventTitle: title, eventDate: timestamp.dateValue(), role: role)
                }
                self.signedUpNewsIds = Set(documents.map { $0.documentID })
            }
    }
    
    func isSignedUp(newsId: String) -> Bool {
        signedUpNewsIds.contains(newsId)
    }
    
    func toggleSignup(newsId: String, eventTitle: String, eventDate: Date, completion: @escaping (Bool) -> Void = { _ in }) {
        if signedUpNewsIds.contains(newsId) {
            cancelSignup(newsId: newsId, completion: completion)
            return
        }
        guard let uid = currentUid else {
            completion(false)
            return
        }
        let data: [String: Any] = [
            "newsId": newsId,
            "eventTitle": eventTitle,
            "eventDate": Timestamp(date: eventDate),
            "role": currentRole.rawValue,
            "signedUpAt": FieldValue.serverTimestamp()
        ]
        db.collection("participants").document(uid).collection("eventSignups").document(newsId)
            .setData(data) { [weak self] error in
                guard let self else { return }
                if error == nil {
                    self.signedUpNewsIds.insert(newsId)
                    self.upcomingSignups.append(EventSignup(id: newsId, newsId: newsId, eventTitle: eventTitle, eventDate: eventDate, role: self.currentRole))
                    self.upcomingSignups.sort { $0.eventDate < $1.eventDate }
                }
                completion(error == nil)
            }
    }
    
    func cancelSignup(newsId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let uid = currentUid else {
            completion(false)
            return
        }
        db.collection("participants").document(uid).collection("eventSignups").document(newsId)
            .delete { [weak self] error in
                guard let self else { return }
                if error == nil {
                    self.signedUpNewsIds.remove(newsId)
                    self.upcomingSignups.removeAll { $0.newsId == newsId }
                }
                completion(error == nil)
            }
    }
}

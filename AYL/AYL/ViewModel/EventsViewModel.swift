//
//  EventsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 13.10.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
internal import Combine

final class EventsViewModel: ObservableObject {
    
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    // MARK: - Fetch
    
    func fetchEvents() {
        isLoading = true
        db.collection("Events")
            .order(by: "eventDate", descending: true)
            .limit(to: 300)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.events = (snapshot?.documents ?? []).compactMap { Self.parse($0) }
            }
    }
    
    private static func parse(_ doc: QueryDocumentSnapshot) -> Event? {
        let data = doc.data()
        guard let typeRaw = data["type"] as? String,
              let type = EventType(rawValue: typeRaw),
              let city = data["city"] as? String,
              let eventTimestamp = data["eventDate"] as? Timestamp,
              let authorUid = data["authorUid"] as? String else { return nil }
        let createdTimestamp = data["createdAt"] as? Timestamp ?? eventTimestamp
        return Event(
            id: doc.documentID,
            type: type,
            title: data["title"] as? String ?? "",
            city: city,
            eventDate: eventTimestamp.dateValue(),
            imageUrl: data["imageUrl"] as? String,
            directorName: data["directorName"] as? String ?? "",
            executiveDirectorName: data["executiveDirectorName"] as? String ?? "",
            adminTeamNames: data["adminTeamNames"] as? String ?? "",
            gammaNames: data["gammaNames"] as? String ?? "",
            facilitatorNames: data["facilitatorNames"] as? String ?? "",
            delegateNames: data["delegateNames"] as? String ?? "",
            photoUrls: data["photoUrls"] as? [String] ?? [],
            authorUid: authorUid,
            createdAt: createdTimestamp.dateValue()
        )
    }
    
    // MARK: - Add / Edit
    
    func saveEvent(
        id: String,
        isNew: Bool,
        type: EventType,
        title: String,
        city: String,
        eventDate: Date,
        imageUrl: String?,
        directorName: String,
        executiveDirectorName: String,
        adminTeamNames: String,
        gammaNames: String,
        facilitatorNames: String,
        delegateNames: String,
        photoUrls: [String],
        authorUid: String,
        completion: @escaping (Bool) -> Void
    ) {
        isSaving = true
        errorMessage = ""
        var data: [String: Any] = [
            "type": type.rawValue,
            "title": title.trimmingCharacters(in: .whitespaces),
            "city": city.trimmingCharacters(in: .whitespaces),
            "eventDate": Timestamp(date: eventDate),
            "directorName": directorName.trimmingCharacters(in: .whitespaces),
            "executiveDirectorName": executiveDirectorName.trimmingCharacters(in: .whitespaces),
            "adminTeamNames": adminTeamNames.trimmingCharacters(in: .whitespaces),
            "gammaNames": gammaNames.trimmingCharacters(in: .whitespaces),
            "facilitatorNames": facilitatorNames.trimmingCharacters(in: .whitespaces),
            "delegateNames": delegateNames.trimmingCharacters(in: .whitespaces),
            "photoUrls": photoUrls,
            "authorUid": authorUid
        ]
        if let imageUrl {
            data["imageUrl"] = imageUrl
        }
        data[isNew ? "createdAt" : "updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection("Events").document(id).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            self.isSaving = false
            if let error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.fetchEvents()
            completion(true)
        }
    }
    
    func deleteEvent(_ event: Event, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("Events").document(event.id).delete { [weak self] error in
            guard let self else { return }
            if let error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.events.removeAll { $0.id == event.id }
            completion(true)
        }
    }
    
    // MARK: - Storage
    
    func uploadCoverImage(eventId: String, imageData: Data, completion: @escaping (String?) -> Void) {
        let ref = Storage.storage().reference().child("event_covers/\(eventId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metadata) { _, error in
            if error != nil { completion(nil); return }
            ref.downloadURL { url, _ in completion(url?.absoluteString) }
        }
    }
    
    func uploadEventPhoto(eventId: String, imageData: Data, completion: @escaping (String?) -> Void) {
        let ref = Storage.storage().reference().child("event_photos/\(eventId)/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metadata) { _, error in
            if error != nil { completion(nil); return }
            ref.downloadURL { url, _ in completion(url?.absoluteString) }
        }
    }
    
    // MARK: - Participation
    
    func markParticipated(in event: Event, uid: String, completion: @escaping (Bool) -> Void) {
        let participantRef = db.collection("participants").document(uid)
        participantRef.getDocument { [weak self] snapshot, _ in
            guard let self else { return }
            let roleRaw = snapshot?.data()?["role"] as? String ?? ""
            let role = ParticipantRole(rawValue: roleRaw) ?? .unspecified
            let data: [String: Any] = [
                "eventTitle": event.displayTitle,
                "eventDate": Timestamp(date: event.eventDate),
                "role": role.rawValue,
                "newsId": event.id,
                "createdAt": FieldValue.serverTimestamp()
            ]
            participantRef.collection("participations").document(event.id)
                .setData(data, merge: true) { error in
                    completion(error == nil)
                }
        }
    }
    
    func checkParticipated(in event: Event, uid: String?, completion: @escaping (Bool) -> Void) {
        guard let uid else { completion(false); return }
        db.collection("participants").document(uid)
            .collection("participations").document(event.id)
            .getDocument { snapshot, _ in completion(snapshot?.exists == true) }
    }
}

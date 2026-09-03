//
//  ProfileViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 03.09.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
internal import Combine

final class ProfileViewModel: ObservableObject {
    
    @Published var participant: Participant?
    @Published var participations: [Participation] = []
    @Published var isLoadingProfile = false
    @Published var isSaving = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    // MARK: - Auth (регистрация / вход)
    
    func register(name: String, phone: String, role: ParticipantRole, email: String, password: String, completion: @escaping (Bool) -> Void) {
        errorMessage = ""
        isSaving = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.isSaving = false
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            guard let uid = result?.user.uid else {
                self.isSaving = false
                self.errorMessage = "Не удалось создать аккаунт"
                completion(false)
                return
            }
            let data: [String: Any] = [
                "name": name.trimmingCharacters(in: .whitespaces),
                "phone": phone.trimmingCharacters(in: .whitespaces),
                "role": role.rawValue,
                "email": email.trimmingCharacters(in: .whitespaces),
                "createdAt": FieldValue.serverTimestamp()
            ]
            self.db.collection("participants").document(uid).setData(data) { error in
                self.isSaving = false
                if let error {
                    self.errorMessage = "Аккаунт создан, но не удалось сохранить профиль: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        errorMessage = ""
        isSaving = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self else { return }
            self.isSaving = false
            if let error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: - Profile
    
    func fetchProfile(uid: String?) {
        guard let uid else {
            participant = nil
            return
        }
        isLoadingProfile = true
        db.collection("participants").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self else { return }
            self.isLoadingProfile = false
            guard let data = snapshot?.data() else { return }
            let timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
            self.participant = Participant(
                id: uid,
                name: data["name"] as? String ?? "",
                phone: data["phone"] as? String ?? "",
                role: ParticipantRole(rawValue: data["role"] as? String ?? "") ?? .alpha,
                email: data["email"] as? String ?? "",
                createdAt: timestamp.dateValue(),
                photoUrl: data["photoUrl"] as? String
            )
        }
    }
    
    func updateProfile(name: String, phone: String, role: ParticipantRole, completion: @escaping (Bool) -> Void) {
        guard let participant else {
            completion(false)
            return
        }
        isSaving = true
        errorMessage = ""
        let data: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "phone": phone.trimmingCharacters(in: .whitespaces),
            "role": role.rawValue
        ]
        db.collection("participants").document(participant.id).updateData(data) { [weak self] error in
            guard let self else { return }
            self.isSaving = false
            if let error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.participant = Participant(
                id: participant.id,
                name: name.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces),
                role: role,
                email: participant.email,
                createdAt: participant.createdAt,
                photoUrl: participant.photoUrl
            )
            completion(true)
        }
    }
    
    // MARK: - Profile's photo
    
    func uploadPhoto(imageData: Data, completion: @escaping (Bool) -> Void) {
        guard let participant else {
            completion(false)
            return
        }
        isSaving = true
        errorMessage = ""
        let ref = Storage.storage().reference().child("participant_photos/\(participant.id).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metadata) { [weak self] _, error in
            guard let self else { return }
            if let error {
                self.isSaving = false
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            ref.downloadURL { [weak self] url, error in
                guard let self else { return }
                self.isSaving = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                guard let url else {
                    self.errorMessage = "Не удалось получить ссылку на фото"
                    completion(false)
                    return
                }
                self.db.collection("participants").document(participant.id)
                    .updateData(["photoUrl": url.absoluteString]) { [weak self] error in
                        guard let self else { return }
                        if let error {
                            self.errorMessage = error.localizedDescription
                            completion(false)
                            return
                        }
                        self.participant = Participant(
                            id: participant.id,
                            name: participant.name,
                            phone: participant.phone,
                            role: participant.role,
                            email: participant.email,
                            createdAt: participant.createdAt,
                            photoUrl: url.absoluteString
                        )
                        completion(true)
                    }
            }
        }
    }
    
    // MARK: - Participation
    
    func fetchParticipations(uid: String?) {
        guard let uid else {
            participations = []
            return
        }
        db.collection("participants").document(uid).collection("participations")
            .order(by: "eventDate", descending: true)
            .getDocuments { [weak self] snapshot, _ in
                guard let self, let documents = snapshot?.documents else { return }
                self.participations = documents.compactMap { doc -> Participation? in
                    let data = doc.data()
                    guard let title = data["eventTitle"] as? String,
                          let timestamp = data["eventDate"] as? Timestamp,
                          let roleRaw = data["role"] as? String,
                          let role = ParticipantRole(rawValue: roleRaw) else { return nil }
                    return Participation(
                        id: doc.documentID,
                        eventTitle: title,
                        eventDate: timestamp.dateValue(),
                        role: role,
                        newsId: data["newsId"] as? String
                    )
                }
            }
    }
    
    func addParticipation(eventTitle: String, eventDate: Date, role: ParticipantRole, completion: @escaping (Bool) -> Void) {
        guard let participant else {
            completion(false)
            return
        }
        isSaving = true
        errorMessage = ""
        let data: [String: Any] = [
            "eventTitle": eventTitle.trimmingCharacters(in: .whitespaces),
            "eventDate": Timestamp(date: eventDate),
            "role": role.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("participants").document(participant.id)
            .collection("participations").document()
            .setData(data) { [weak self] error in
                guard let self else { return }
                self.isSaving = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self.fetchParticipations(uid: participant.id)
                completion(true)
            }
    }
}

//
//  QuizViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

struct QuizProfileSummary {
    let name: String
    let role: ParticipantRole
    let photoUrl: String?
}

class QuizViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var questions = [QuizQuestion]()
    @Published var isLoadingQuestions = true
    @Published var leaderboard = [PublicProfile]()
    @Published var isLoadingLeaderboard = true
    
    private var db = Firestore.firestore()
    private var questionsListener: ListenerRegistration?
    private var leaderboardListener: ListenerRegistration?
    
    // MARK: - Questions
    
    func fetchQuestions() {
        questionsListener?.remove()
        questionsListener = db.collection("QuizQuestions")
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoadingQuestions = false
                guard let documents = snapshot?.documents else {
                    print("Ошибка загрузки вопросов квиза: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.questions = documents.compactMap { doc -> QuizQuestion? in
                    let data = doc.data()
                    guard let text = data["text"] as? String,
                          let options = data["options"] as? [String],
                          let correctIndex = data["correctIndex"] as? Int else { return nil }
                    return QuizQuestion(id: doc.documentID, text: text, options: options, correctIndex: correctIndex)
                }
            }
    }
    
    deinit {
        questionsListener?.remove()
        leaderboardListener?.remove()
    }
    
    // MARK: - Admin(Add/Update/Delete Questions)
    
    func addQuestion(text: String, options: [String], correctIndex: Int) {
        let data: [String: Any] = [
            "text": text,
            "options": options,
            "correctIndex": correctIndex,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("QuizQuestions").addDocument(data: data) { error in
            if let error {
                print("Ошибка добавления вопроса: \(error.localizedDescription)")
            }
        }
    }
    
    func updateQuestion(id: String, text: String, options: [String], correctIndex: Int) {
        let data: [String: Any] = [
            "text": text,
            "options": options,
            "correctIndex": correctIndex
        ]
        db.collection("QuizQuestions").document(id).updateData(data) { error in
            if let error {
                print("Ошибка обновления вопроса: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteQuestion(id: String) {
        db.collection("QuizQuestions").document(id).delete { error in
            if let error {
                print("Ошибка удаления вопроса: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Rating
    
    func fetchLeaderboard() {
        leaderboardListener?.remove()
        leaderboardListener = db.collection("PublicProfiles")
            .order(by: "quizBestScore", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoadingLeaderboard = false
                guard let documents = snapshot?.documents else {
                    print("Ошибка загрузки рейтинга: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self.leaderboard = documents.compactMap { doc -> PublicProfile? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let roleRaw = data["role"] as? String,
                          let role = ParticipantRole(rawValue: roleRaw) else { return nil }
                    return PublicProfile(
                        id: doc.documentID,
                        name: name,
                        role: role,
                        photoUrl: data["photoUrl"] as? String,
                        quizBestScore: data["quizBestScore"] as? Int ?? 0,
                        quizBestTotal: data["quizBestTotal"] as? Int ?? 0
                    )
                }
            }
    }
    
    // MARK: - Result
    
    func fetchMyProfileSummary(uid: String, completion: @escaping (QuizProfileSummary?) -> Void) {
        db.collection("participants").document(uid).getDocument { snapshot, _ in
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let roleRaw = data["role"] as? String,
                  let role = ParticipantRole(rawValue: roleRaw) else {
                completion(nil)
                return
            }
            completion(QuizProfileSummary(name: name, role: role, photoUrl: data["photoUrl"] as? String))
        }
    }
    
    // MARK: - Participation in Events
    
    func fetchParticipations(uid: String, completion: @escaping ([Participation]) -> Void) {
        db.collection("participants").document(uid).collection("participations")
            .order(by: "eventDate", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Ошибка загрузки участия: \(error?.localizedDescription ?? "unknown")")
                    completion([])
                    return
                }
                let items = documents.compactMap { doc -> Participation? in
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
                completion(items)
            }
    }
    
    func submitResult(uid: String, name: String, role: ParticipantRole, photoUrl: String?, score: Int, total: Int, completion: @escaping (Bool) -> Void = { _ in }) {
        let ref = db.collection("PublicProfiles").document(uid)
        ref.getDocument { snapshot, _ in
            let currentBest = snapshot?.data()?["quizBestScore"] as? Int ?? -1
            var data: [String: Any] = [
                "name": name,
                "role": role.rawValue
            ]
            if let photoUrl {
                data["photoUrl"] = photoUrl
            }
            if score > currentBest {
                data["quizBestScore"] = score
                data["quizBestTotal"] = total
                data["quizBestAt"] = FieldValue.serverTimestamp()
            }
            ref.setData(data, merge: true) { error in
                if let error {
                    print("Ошибка сохранения результата квиза: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
}

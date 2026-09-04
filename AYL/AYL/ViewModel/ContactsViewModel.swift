//
//  ContactsViewModel.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import SwiftUI
import FirebaseFirestore
internal import Combine

class ContactsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var info: ContactsInfo = .default
    @Published var isLoading = true
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Data Fetching
    
    func fetchData() {
        listener?.remove()
        listener = db.collection("Settings").document("contacts")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                guard let data = snapshot?.data() else {
                    if let error {
                        print("Ошибка загрузки контактов: \(error.localizedDescription)")
                    }
                    return
                }
                self.info = ContactsInfo(
                    website: data["website"] as? String ?? ContactsInfo.default.website,
                    email: data["email"] as? String ?? ContactsInfo.default.email,
                    phone: data["phone"] as? String ?? ContactsInfo.default.phone,
                    telegram: data["telegram"] as? String ?? ContactsInfo.default.telegram,
                    vk: data["vk"] as? String ?? ContactsInfo.default.vk,
                    youtube: data["youtube"] as? String ?? ContactsInfo.default.youtube,
                    directorTitle: data["directorTitle"] as? String ?? ContactsInfo.default.directorTitle,
                    directorName: data["directorName"] as? String ?? ContactsInfo.default.directorName
                )
            }
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Admin Actions
    
    func updateContacts(_ info: ContactsInfo, completion: @escaping (Bool) -> Void = { _ in }) {
        let data: [String: Any] = [
            "website": info.website,
            "email": info.email,
            "phone": info.phone,
            "telegram": info.telegram,
            "vk": info.vk,
            "youtube": info.youtube,
            "directorTitle": info.directorTitle,
            "directorName": info.directorName
        ]
        db.collection("Settings").document("contacts").setData(data, merge: true) { error in
            if let error {
                print("Ошибка сохранения контактов: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

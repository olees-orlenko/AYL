//
//  AuthManager.swift
//  AYL
//
//  Created by Олеся Орленко on 16.04.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
internal import Combine

class AuthManager: ObservableObject {
    @Published var isAdminLoggedIn: Bool = false
    @Published var isParticipantLoggedIn: Bool = false
    @Published var currentUserId: String? = nil
    
    private var handler: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        DispatchQueue.main.async {
            self.handler = Auth.auth().addStateDidChangeListener { _, user in
                self.currentUserId = user?.uid
                guard let uid = user?.uid else {
                    self.isAdminLoggedIn = false
                    self.isParticipantLoggedIn = false
                    return
                }
                self.db.collection("admins").document(uid).getDocument { snapshot, error in
                    let isAdmin = (snapshot?.exists == true)
                    DispatchQueue.main.async {
                        self.isAdminLoggedIn = isAdmin
                        self.isParticipantLoggedIn = !isAdmin
                    }
                }
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}

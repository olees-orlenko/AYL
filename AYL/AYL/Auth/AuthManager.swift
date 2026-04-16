//
//  AuthManager.swift
//  AYL
//
//  Created by Олеся Орленко on 16.04.2026.
//

import SwiftUI
import FirebaseAuth
internal import Combine

class AuthManager: ObservableObject {
    @Published var isAdminLoggedIn: Bool = false
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        handler = Auth.auth().addStateDidChangeListener { _, user in
            self.isAdminLoggedIn = (user != nil)
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

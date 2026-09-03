//
//  LoginView.swift
//  AYL
//
//  Created by Олеся Орленко on 16.04.2026.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Пароль", text: $password)
                } footer: {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button("Войти") {
                    login()
                }
                .frame(maxWidth: .infinity)
                .bold()
            }
            .navigationTitle("Вход для админа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                dismiss()
            }
        }
    }
}

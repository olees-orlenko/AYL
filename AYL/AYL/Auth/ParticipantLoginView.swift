//
//  ParticipantLoginView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI

struct ParticipantLoginView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingResetConfirmation = false
    
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }
    
    private var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button {
                    login()
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || viewModel.isSaving)
                Button("Забыли пароль?") {
                    resetPassword()
                }
                .disabled(!isEmailValid || viewModel.isSaving)
                .font(.footnote)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Вход в личный кабинет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .alert("Письмо отправлено", isPresented: $showingResetConfirmation) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text("Проверьте почту \(email) — там ссылка для восстановления пароля.")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func login() {
        viewModel.login(email: email, password: password) { success in
            if success {
                dismiss()
            }
        }
    }
    
    private func resetPassword() {
        viewModel.resetPassword(email: email) { success in
            if success {
                showingResetConfirmation = true
            }
        }
    }
}

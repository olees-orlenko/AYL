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

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
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
            }
            .navigationTitle("Вход в личный кабинет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
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
}

//
//  RegisterView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI

struct RegisterView: View {

    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    @State private var name = ""
    @State private var phone = ""
    @State private var role: ParticipantRole = .alpha
    @State private var email = ""
    @State private var password = ""

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Данные участника") {
                    TextField("Имя", text: $name)
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                    Picker("Роль", selection: $role) {
                        ForEach(ParticipantRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }
                Section("Вход") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Пароль (минимум 6 символов)", text: $password)
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button {
                    register()
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || viewModel.isSaving)
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    // MARK: - Private methods

    private func register() {
        viewModel.register(name: name, phone: phone, role: role, email: email, password: password) { success in
            if success {
                dismiss()
            }
        }
    }
}

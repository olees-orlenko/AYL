//
//  RegisterView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var role: ParticipantRole = .alpha
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }
    
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
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button {
                    register()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || isLoading)
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
    
    private func register() {
        errorMessage = ""
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                return
            }
            guard let uid = result?.user.uid else {
                isLoading = false
                errorMessage = "Не удалось создать аккаунт"
                return
            }
            let data: [String: Any] = [
                "name": name.trimmingCharacters(in: .whitespaces),
                "phone": phone.trimmingCharacters(in: .whitespaces),
                "role": role.rawValue,
                "email": email.trimmingCharacters(in: .whitespaces),
                "createdAt": FieldValue.serverTimestamp()
            ]
            Firestore.firestore().collection("participants").document(uid).setData(data) { error in
                isLoading = false
                if let error = error {
                    errorMessage = "Аккаунт создан, но не удалось сохранить профиль: \(error.localizedDescription)"
                    return
                }
                dismiss()
            }
        }
    }
}

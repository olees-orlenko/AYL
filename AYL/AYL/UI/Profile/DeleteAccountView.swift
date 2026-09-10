//
//  DeleteAccountView.swift
//  AYL
//
//  Created by Олеся Орленко on 10.09.2026.
//

import SwiftUI

struct DeleteAccountView: View {

    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    @State private var password = ""
    @State private var isConfirming = false

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Аккаунт и все связанные данные — профиль, история участия, заявки на сертификаты и контакты — будут удалены безвозвратно. Это действие нельзя отменить.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Section("Подтверждение") {
                    SecureField("Введите пароль", text: $password)
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button(role: .destructive) {
                    isConfirming = true
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Удалить аккаунт")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(password.isEmpty || viewModel.isSaving)
            }
            .navigationTitle("Удаление аккаунта")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .confirmationDialog(
                "Удалить аккаунт без возможности восстановления?",
                isPresented: $isConfirming,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) { deleteAccount() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    // MARK: - Private methods
    
    private func deleteAccount() {
        viewModel.deleteAccount(password: password) { success in
            if success {
                dismiss()
            }
        }
    }
}

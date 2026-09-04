//
//  ContactsEditView.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import SwiftUI

struct ContactsEditView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ContactsViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var website: String
    @State private var email: String
    @State private var phone: String
    @State private var telegram: String
    @State private var vk: String
    @State private var youtube: String
    @State private var directorTitle: String
    @State private var directorName: String
    @State private var isSaving = false
    
    // MARK: - Init
    
    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
        let info = viewModel.info
        _website = State(initialValue: info.website)
        _email = State(initialValue: info.email)
        _phone = State(initialValue: info.phone)
        _telegram = State(initialValue: info.telegram)
        _vk = State(initialValue: info.vk)
        _youtube = State(initialValue: info.youtube)
        _directorTitle = State(initialValue: info.directorTitle)
        _directorName = State(initialValue: info.directorName)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Сайт (например, https://ayl.ru)", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("Электронная почта", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                }
                Section("Социальные сети") {
                    TextField("Telegram", text: $telegram)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("ВКонтакте", text: $vk)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("YouTube", text: $youtube)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                Section("Руководитель") {
                    TextField("Должность", text: $directorTitle)
                    TextField("Имя", text: $directorName)
                }
            }
            .navigationTitle("Контакты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveAction()
                    }
                    .disabled(website.isEmpty || email.isEmpty || phone.isEmpty || !authManager.isAdminLoggedIn || isSaving)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func saveAction() {
        isSaving = true
        let updated = ContactsInfo(
            website: website.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            telegram: telegram.trimmingCharacters(in: .whitespaces),
            vk: vk.trimmingCharacters(in: .whitespaces),
            youtube: youtube.trimmingCharacters(in: .whitespaces),
            directorTitle: directorTitle.trimmingCharacters(in: .whitespaces),
            directorName: directorName.trimmingCharacters(in: .whitespaces)
        )
        viewModel.updateContacts(updated) { _ in
            isSaving = false
            dismiss()
        }
    }
}

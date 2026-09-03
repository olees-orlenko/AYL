//
//  EditProfileView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI

struct EditProfileView: View {

    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    let participant: Participant

    @State private var name: String
    @State private var phone: String
    @State private var role: ParticipantRole

    // MARK: - Init

    init(viewModel: ProfileViewModel, participant: Participant) {
        self.viewModel = viewModel
        self.participant = participant
        _name = State(initialValue: participant.name)
        _phone = State(initialValue: participant.phone)
        _role = State(initialValue: participant.role)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Профиль") {
                    TextField("Имя", text: $name)
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                    Picker("Роль", selection: $role) {
                        ForEach(ParticipantRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button {
                    save()
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSaving)
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    // MARK: - Private methods

    private func save() {
        viewModel.updateProfile(name: name, phone: phone, role: role) { success in
            if success {
                dismiss()
            }
        }
    }
}

//
//  AddParticipationView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI

struct AddParticipationView: View {

    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var role: ParticipantRole = .alpha

    private var isFormValid: Bool {
        !eventTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Мероприятие") {
                    TextField("Название", text: $eventTitle)
                    DatePicker("Дата", selection: $eventDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                    Picker("Роль на этом мероприятии", selection: $role) {
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
                        Text("Добавить")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || viewModel.isSaving)
            }
            .navigationTitle("Участие в мероприятии")
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
        viewModel.addParticipation(eventTitle: eventTitle, eventDate: eventDate, role: role) { success in
            if success {
                dismiss()
            }
        }
    }
}

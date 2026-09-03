//
//  EditProfileView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    let participant: Participant
    var onSaved: (Participant) -> Void
    
    @State private var name: String
    @State private var phone: String
    @State private var role: ParticipantRole
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    // MARK: - Init
    
    init(participant: Participant, onSaved: @escaping (Participant) -> Void) {
        self.participant = participant
        self.onSaved = onSaved
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
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Button {
                    save()
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
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
        isSaving = true
        errorMessage = ""
        let data: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "phone": phone.trimmingCharacters(in: .whitespaces),
            "role": role.rawValue
        ]
        Firestore.firestore().collection("participants").document(participant.id).updateData(data) { error in
            isSaving = false
            if let error {
                errorMessage = error.localizedDescription
                return
            }
            let updated = Participant(
                id: participant.id,
                name: name.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces),
                role: role,
                email: participant.email,
                createdAt: participant.createdAt
            )
            onSaved(updated)
            dismiss()
        }
    }
}

//
//  AddParticipationView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI
import FirebaseFirestore

struct AddParticipationView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    let participantId: String
    var onSaved: () -> Void
    
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var role: ParticipantRole = .alpha
    @State private var isSaving = false
    @State private var errorMessage = ""
    
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
                        Text("Добавить")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || isSaving)
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
        isSaving = true
        errorMessage = ""
        let data: [String: Any] = [
            "eventTitle": eventTitle.trimmingCharacters(in: .whitespaces),
            "eventDate": Timestamp(date: eventDate),
            "role": role.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        Firestore.firestore()
            .collection("participants").document(participantId)
            .collection("participations").document()
            .setData(data) { error in
                isSaving = false
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }
                onSaved()
                dismiss()
            }
    }
}

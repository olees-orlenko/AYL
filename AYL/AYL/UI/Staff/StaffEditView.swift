//
//  StaffEditView.swift
//  AYL
//
//  Created by Олеся Орленко on 16.04.2026.
//

import SwiftUI

struct StaffEditView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: StaffViewModel
    var member: StaffMember?
    @State private var name: String = ""
    @State private var position: String = ""
    @State private var bio: String = ""
    @State private var photoName: String = ""
    @State private var telegramLink: String = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                    TextField("ФИО", text: $name)
                    TextField("Должность", text: $position)
                    TextField("Ссылка на фото (Direct Link)", text: $photoName)
                    TextField("Ссылка на Telegram", text: $telegramLink)
                    TextField("Несколько слов об АЮЛ", text: $bio)
                if member != nil {
                    Button(role: .destructive) {
                        if let id = member?.id {
                            viewModel.deleteMember(id: id)
                            dismiss()
                        }
                    } label: {
                        Text("Удалить участника")
                    }
                }
            }
            .navigationTitle(member == nil ? "Новый участник" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveAction()
                        dismiss()
                    }
                    .disabled(name.isEmpty || position.isEmpty)
                }
            }
            .onAppear {
                if let member = member {
                    name = member.name
                    position = member.position
                    bio = member.bio
                    photoName = member.photoName
                    telegramLink = member.telegramLink ?? ""
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func saveAction() {
        if let id = member?.id {
            viewModel.updateMember(id: id, name: name, position: position, bio: bio, photoName: photoName, telegramLink: telegramLink)
        } else {
            viewModel.addMember(name: name, position: position, bio: bio, photoName: photoName, telegramLink: telegramLink)
        }
    }
}

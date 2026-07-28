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
    @EnvironmentObject var authManager: AuthManager
    var member: StaffMember?
    @State private var name: String = ""
    @State private var position: String = ""
    @State private var bio: String = ""
    @State private var photoName: String = ""
    @State private var telegramLink: String = ""
    
    // MARK: - Init
    
    init(viewModel: StaffViewModel, member: StaffMember?) {
        self.viewModel = viewModel
        self.member = member
        _name = State(initialValue: member?.name ?? "")
        _position = State(initialValue: member?.position ?? "")
        _bio = State(initialValue: member?.bio ?? "")
        _photoName = State(initialValue: member?.photoName ?? "")
        _telegramLink = State(initialValue: member?.telegramLink ?? "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("ФИО", text: $name)
                TextField("Должность", text: $position)
                TextField("Ссылка на фото (Direct Link)", text: $photoName)
                TextField("Ссылка на Telegram", text: $telegramLink)
                TextField("Несколько слов об АЮЛ", text: $bio)
                if member != nil && authManager.isAdminLoggedIn{
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
                    .disabled(name.isEmpty || position.isEmpty || !authManager.isAdminLoggedIn)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func saveAction() {
        if let id = member?.id {
            viewModel.updateMember(id: id, name: name, position: position, bio: bio, photoName: photoName, telegramLink: telegramLink)
        } else {
            if authManager.isAdminLoggedIn {
                viewModel.addMember(name: name, position: position, bio: bio, photoName: photoName, telegramLink: telegramLink)
            }
        }
    }
}

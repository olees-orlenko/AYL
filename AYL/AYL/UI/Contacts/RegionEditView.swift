//
//  RegionEditView.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import SwiftUI

struct RegionEditView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RegionsViewModel
    @EnvironmentObject var authManager: AuthManager
    var region: RegionContact?
    @State private var name: String = ""
    @State private var telegramLink: String = ""
    @State private var vkLink: String = ""
    @State private var websiteLink: String = ""
    
    // MARK: - Init
    
    init(viewModel: RegionsViewModel, region: RegionContact?) {
        self.viewModel = viewModel
        self.region = region
        _name = State(initialValue: region?.name ?? "")
        _telegramLink = State(initialValue: region?.telegramLink ?? "")
        _vkLink = State(initialValue: region?.vkLink ?? "")
        _websiteLink = State(initialValue: region?.websiteLink ?? "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название региона", text: $name)
                }
                Section("Ссылки (необязательно)") {
                    TextField("Telegram", text: $telegramLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("ВКонтакте", text: $vkLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("Сайт", text: $websiteLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                if region != nil && authManager.isAdminLoggedIn {
                    Button(role: .destructive) {
                        if let id = region?.id {
                            viewModel.deleteRegion(id: id)
                            dismiss()
                        }
                    } label: {
                        Text("Удалить регион")
                    }
                }
            }
            .navigationTitle(region == nil ? "Новый регион" : "Редактирование")
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
                    .disabled(name.isEmpty || !authManager.isAdminLoggedIn)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func saveAction() {
        if let id = region?.id {
            viewModel.updateRegion(id: id, name: name, telegramLink: telegramLink, vkLink: vkLink, websiteLink: websiteLink)
        } else {
            if authManager.isAdminLoggedIn {
                viewModel.addRegion(name: name, telegramLink: telegramLink, vkLink: vkLink, websiteLink: websiteLink)
            }
        }
    }
}

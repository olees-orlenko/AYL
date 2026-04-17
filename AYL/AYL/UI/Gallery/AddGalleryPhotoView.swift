//
//  AddGalleryPhotoView.swift
//  AYL
//
//  Created by Олеся Орленко on 17.04.2026.
//

import SwiftUI

struct AddGalleryPhotoView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GalleryViewModel
    @State private var title = ""
    @State private var imageUrl = ""
    @State private var imageUrlsText = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Мероприятие") {
                    TextField("Название (например: Конференция 2026)", text: $title)
                }
                Section("Ссылки на фото (каждая с новой строки)") {
                    TextEditor(text: $imageUrlsText)
                        .frame(minHeight: 200)
                        .font(.system(size: 14, design: .monospaced))
                }
            }
            .navigationTitle("Загрузка фотографий")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        savePhotos()
                    }
                    .disabled(title.isEmpty || imageUrlsText.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func savePhotos() {
        let urls = imageUrlsText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        viewModel.addMultiplePhotos(title: title, imageUrls: urls)
        dismiss()
    }
}

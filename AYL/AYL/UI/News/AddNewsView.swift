//
//  AddNewsView.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI

struct AddNewsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: NewsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var imageUrl: String = ""
    @State private var content: String = ""
    @State private var linkUrl: String = ""
    var isFormValid: Bool {
        !title.isEmpty && !imageUrl.isEmpty && !content.isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Заголовок новости", text: $title)
                    TextField("Ссылка на изображение", text: $imageUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Ссылка на источник (подробнее)", text: $linkUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                Section(header: Text("Текст новости")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                if !imageUrl.isEmpty {
                    Section(header: Text("Предпросмотр фото")) {
                        AsyncImage(url: URL(string: imageUrl.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .clipped()
                            } else {
                                Text("Загрузка фото или неверная ссылка...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Добавить новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.addNews(title: title, content: content, imageUrl: imageUrl, linkUrl: linkUrl)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

// MARK: - Preview

struct AddNewsView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewsView(viewModel: NewsViewModel())
    }
}

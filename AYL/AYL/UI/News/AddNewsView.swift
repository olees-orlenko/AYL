//
//  AddNewsView.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI
import Kingfisher

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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Заголовок новости")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextField("Введите название...", text: $title)
                    }
                    .padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ссылка на изображение")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextField("https://...", text: $imageUrl)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ссылка на источник (подробнее)")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextField("https://...", text: $linkUrl)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 2)
                }
                Section(header: Text("Текст новости")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Основное содержание")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                    }
                }
                if !imageUrl.isEmpty {
                    Section(header: Text("Предпросмотр фото")) {
                        KFImage(URL(string: imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)))
                            .placeholder {
                                Text("Загрузка фото или неверная ссылка...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .cornerRadius(10)
                            .clipped()
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

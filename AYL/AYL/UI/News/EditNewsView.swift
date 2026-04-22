//
//  EditNewsView.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI

struct EditNewsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: NewsViewModel
    let newsItem: NewsItem
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var imageUrl: String = ""
    @State private var content: String = ""
    @State private var linkUrl: String = ""
    @State private var titleError: String? = nil
    @State private var imageUrlError: String? = nil
    @State private var contentError: String? = nil
    @State private var linkUrlError: String? = nil
    private var areMandatoryFieldsFilled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !imageUrl.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }
    @State private var isOverallFormValid: Bool = false
    
    // MARK: - Init
    
    init(viewModel: NewsViewModel, newsItem: NewsItem) {
        self.viewModel = viewModel
        self.newsItem = newsItem
        _title = State(initialValue: newsItem.title)
        _imageUrl = State(initialValue: newsItem.imageUrl)
        _content = State(initialValue: newsItem.content)
        _linkUrl = State(initialValue: newsItem.linkUrl)
    }
    
    // MARK: - Validation
    
    func validateForm() {
        var isValid = true
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "Заголовок новости не может быть пустым."
            isValid = false
        } else if title.count > 100 {
            titleError = "Заголовок слишком длинный (макс. 100 символов)."
            isValid = false
        } else {
            titleError = nil
        }
        let trimmedImageUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedImageUrl.isEmpty {
            imageUrlError = "Ссылка на фото не может быть пустой."
            isValid = false
        } else if !isValidUrl(trimmedImageUrl) {
            imageUrlError = "Неверный формат ссылки. Должна начинаться с http:// или https://."
            isValid = false
        } else if !isValidImageUrlExtension(trimmedImageUrl) {
            imageUrlError = "Ссылка должна вести на изображение (.jpg, .png, .gif)."
            isValid = false
        } else {
            imageUrlError = nil
        }
        if content.trimmingCharacters(in: .whitespaces).isEmpty {
            contentError = "Текст новости не может быть пустым."
            isValid = false
        } else if content.count < 20 {
            contentError = "Текст новости слишком короткий (мин. 20 символов)."
            isValid = false
        } else if content.count > 2000 {
            contentError = "Текст новости слишком длинный (макс. 2000 символов)."
            isValid = false
        } else {
            contentError = nil
        }
        let trimmedLinkUrl = linkUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedLinkUrl.isEmpty && !isValidUrl(trimmedLinkUrl) {
            linkUrlError = "Неверный формат ссылки. Должна начинаться с http:// или https://."
            isValid = false
        } else {
            linkUrlError = nil
        }
        isOverallFormValid = isValid
    }
    
    private func isValidUrl(_ urlString: String) -> Bool {
        URL(string: urlString) != nil && (urlString.hasPrefix("http://") || urlString.hasPrefix("https://"))
    }
    
    private func isValidImageUrlExtension(_ urlString: String) -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif"]
        if let url = URL(string: urlString) {
            let ext = url.pathExtension.lowercased()
            return validExtensions.contains(ext)
        }
        return false
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
                            .onChangeCompat(of: title) { validateForm() }
                    }
                    .padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ссылка на изображение")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextField("https://...", text: $imageUrl)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChangeCompat(of: imageUrl) { validateForm() }
                    }
                    .padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ссылка на источник (подробнее)")
                            .font(.caption)
                            .foregroundColor(.violet)
                        TextField("https://...", text: $linkUrl)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChangeCompat(of: linkUrl) { validateForm() }
                    }
                    .padding(.vertical, 2)
                }
                if let titleError = titleError { Text(titleError).font(.caption).foregroundColor(.red) }
                if let imageUrlError = imageUrlError { Text(imageUrlError).font(.caption).foregroundColor(.red) }
                if let linkUrlError = linkUrlError { Text(linkUrlError).font(.caption).foregroundColor(.red) }
                Section(header: Text("Текст новости")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .onChangeCompat(of: content) { validateForm() }
                    
                    if let contentError = contentError { Text(contentError).font(.caption).foregroundColor(.red) }
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
            .navigationTitle("Редактировать новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if isOverallFormValid {
                            viewModel.updateNews(id: newsItem.id, title: title, content: content, imageUrl: imageUrl, linkUrl: linkUrl)
                            dismiss()
                        }
                    }
                    .disabled(!areMandatoryFieldsFilled || !isOverallFormValid)
                }
            }
        }
        .onAppear {
            validateForm()
        }
    }
}

extension View {
    @ViewBuilder
    func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { action() }
        } else {
            self.onChange(of: value) { _ in action() }
        }
    }
}

// MARK: - Preview

struct EditNewsView_Previews: PreviewProvider {
    static var previews: some View {
        EditNewsView(
            viewModel: NewsViewModel(),
            newsItem: NewsItem(
                id: "preview-id",
                title: "Пример заголовка",
                content: "Пример текста новости.",
                imageUrl: "https://via.placeholder.com/300x150/aabbcc/ffffff?text=News+Image",
                date: Date(),
                linkUrl: "https://example.com"
            )
        )
    }
}

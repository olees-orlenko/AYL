//
//  QuizQuestionEditView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI

struct QuizQuestionEditView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: QuizViewModel
    @EnvironmentObject var authManager: AuthManager
    var question: QuizQuestion?
    
    @State private var text: String
    @State private var options: [String]
    @State private var correctIndex: Int
    
    // MARK: - Init
    
    init(viewModel: QuizViewModel, question: QuizQuestion?) {
        self.viewModel = viewModel
        self.question = question
        _text = State(initialValue: question?.text ?? "")
        _options = State(initialValue: question?.options ?? ["", ""])
        _correctIndex = State(initialValue: question?.correctIndex ?? 0)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Вопрос") {
                    TextField("Текст вопроса", text: $text)
                }
                Section("Варианты ответа") {
                    ForEach(options.indices, id: \.self) { index in
                        HStack {
                            TextField("Вариант \(index + 1)", text: binding(for: index))
                            if options.count > 2 {
                                Button {
                                    removeOption(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    if options.count < 6 {
                        Button {
                            options.append("")
                        } label: {
                            Label("Добавить вариант", systemImage: "plus.circle.fill")
                        }
                    }
                }
                Section("Правильный ответ") {
                    Picker("Правильный вариант", selection: $correctIndex) {
                        ForEach(options.indices, id: \.self) { index in
                            Text(options[index].isEmpty ? "Вариант \(index + 1)" : options[index])
                                .tag(index)
                        }
                    }
                }
                if question != nil && authManager.isAdminLoggedIn {
                    Button(role: .destructive) {
                        if let id = question?.id {
                            viewModel.deleteQuestion(id: id)
                            dismiss()
                        }
                    } label: {
                        Text("Удалить вопрос")
                    }
                }
            }
            .navigationTitle(question == nil ? "Новый вопрос" : "Редактирование")
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
                    .disabled(!isValid || !authManager.isAdminLoggedIn)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private var isValid: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
        && options.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        && options.indices.contains(correctIndex)
    }
    
    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { options[index] },
            set: { options[index] = $0 }
        )
    }
    
    private func removeOption(at index: Int) {
        options.remove(at: index)
        if correctIndex >= options.count {
            correctIndex = options.count - 1
        } else if index < correctIndex {
            correctIndex -= 1
        }
    }
    
    private func saveAction() {
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        let trimmedOptions = options.map { $0.trimmingCharacters(in: .whitespaces) }
        if let id = question?.id {
            viewModel.updateQuestion(id: id, text: trimmedText, options: trimmedOptions, correctIndex: correctIndex)
        } else {
            if authManager.isAdminLoggedIn {
                viewModel.addQuestion(text: trimmedText, options: trimmedOptions, correctIndex: correctIndex)
            }
        }
    }
}

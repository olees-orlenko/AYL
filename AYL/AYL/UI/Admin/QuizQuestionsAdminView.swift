//
//  QuizQuestionsAdminView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI

struct QuizQuestionsAdminView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: QuizViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAddSheet = false
    @State private var selectedQuestion: QuizQuestion? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.questions.isEmpty {
                    Text("Вопросов пока нет")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.questions) { question in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.text)
                                .font(.system(size: 16, weight: .semibold))
                            if question.options.indices.contains(question.correctIndex) {
                                Text("Правильный: \(question.options[question.correctIndex])")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedQuestion = question
                        }
                    }
                    .onDelete(perform: deleteQuestions)
                }
            }
            .refreshable {
                viewModel.fetchQuestions()
            }
            .navigationTitle("Вопросы квиза")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedQuestion = nil
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $selectedQuestion) { question in
                QuizQuestionEditView(viewModel: viewModel, question: question)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingAddSheet) {
                QuizQuestionEditView(viewModel: viewModel, question: nil)
                    .environmentObject(authManager)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func deleteQuestions(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteQuestion(id: viewModel.questions[index].id)
        }
    }
}

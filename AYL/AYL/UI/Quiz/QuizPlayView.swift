//
//  QuizPlayView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI

struct QuizPlayView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: QuizViewModel
    
    @State private var currentIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var score = 0
    @State private var isFinished = false
    @State private var isSaving = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.questions.isEmpty {
                    emptyState
                } else if isFinished {
                    resultView
                } else {
                    questionView
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Квиз пока пуст — вопросы ещё не добавлены")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var questionView: some View {
        let question = viewModel.questions[currentIndex]
        return VStack(alignment: .leading, spacing: 20) {
            Text("Вопрос \(currentIndex + 1) из \(viewModel.questions.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(question.text)
                .font(.title3.bold())
            VStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { index in
                    optionButton(text: question.options[index], index: index)
                }
            }
            Spacer()
            Button {
                nextQuestion()
            } label: {
                Text(currentIndex == viewModel.questions.count - 1 ? "Завершить" : "Дальше")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOption == nil ? Color.gray.opacity(0.3) : Color.minty)
                    .cornerRadius(15)
            }
            .disabled(selectedOption == nil)
        }
    }
    
    private func optionButton(text: String, index: Int) -> some View {
        Button {
            selectedOption = index
        } label: {
            HStack {
                Text(text)
                Spacer()
                if selectedOption == index {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            .background(selectedOption == index ? Color.minty.opacity(0.15) : Color.gray.opacity(0.08))
            .foregroundColor(selectedOption == index ? .minty : .primary)
            .cornerRadius(12)
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "rosette")
                .font(.system(size: 60))
                .foregroundColor(.violet)
            Text("\(score) из \(viewModel.questions.count)")
                .font(.largeTitle.bold())
            Text(isSaving ? "Сохраняем результат…" : "Результат сохранён")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Готово")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.minty)
                    .cornerRadius(15)
            }
            .disabled(isSaving)
        }
    }
    
    // MARK: - Private methods
    
    private func nextQuestion() {
        guard let selectedOption else { return }
        if selectedOption == viewModel.questions[currentIndex].correctIndex {
            score += 1
        }
        self.selectedOption = nil
        if currentIndex == viewModel.questions.count - 1 {
            finish()
        } else {
            currentIndex += 1
        }
    }
    
    private func finish() {
        isFinished = true
        guard let uid = authManager.currentUserId else { return }
        isSaving = true
        viewModel.fetchMyProfileSummary(uid: uid) { summary in
            guard let summary else {
                isSaving = false
                return
            }
            viewModel.submitResult(
                uid: uid,
                name: summary.name,
                role: summary.role,
                photoUrl: summary.photoUrl,
                score: score,
                total: viewModel.questions.count
            ) { _ in
                isSaving = false
            }
        }
    }
}

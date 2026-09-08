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
            ZStack {
                Image("QuizWallpaper")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
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
            }
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
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                Capsule()
                    .fill(Color.minty)
                    .frame(width: geo.size.width * progressFraction)
            }
        }
        .frame(height: 8)
    }
    
    private var progressFraction: CGFloat {
        guard !viewModel.questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(viewModel.questions.count)
    }
    
    private var questionView: some View {
        let question = viewModel.questions[currentIndex]
        return VStack(alignment: .leading, spacing: 20) {
            progressBar
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
        let isSelected = selectedOption == index
        return Button {
            selectedOption = index
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.minty : Color.gray.opacity(0.15))
                        .frame(width: 32, height: 32)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text(optionLetter(for: index))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                Text(text)
                    .foregroundColor(isSelected ? .minty : .primary)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.minty.opacity(0.12) : Color(.secondarySystemBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.03), radius: 6, x: 0, y: 3)
        }
    }
    
    private func optionLetter(for index: Int) -> String {
        let letters = ["А", "Б", "В", "Г", "Д", "Е"]
        return letters.indices.contains(index) ? letters[index] : "\(index + 1)"
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.lightBlue, Color.violet, Color.minty],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "rosette")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
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

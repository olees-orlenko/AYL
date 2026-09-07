//
//  QuizHomeView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI

struct QuizHomeView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingPlay = false
    @State private var showingLeaderboard = false
    @State private var showingAdmin = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if authManager.isParticipantLoggedIn {
                    actionButton(title: "Пройти квиз", systemImage: "questionmark.circle.fill") {
                        showingPlay = true
                    }
                    actionButton(title: "Рейтинг участников", systemImage: "list.number") {
                        showingLeaderboard = true
                    }
                    if authManager.isAdminLoggedIn {
                        actionButton(title: "Управление вопросами", systemImage: "gearshape.fill") {
                            showingAdmin = true
                        }
                    }
                } else {
                    Text("Войдите в личный кабинет участника (иконка профиля рядом), чтобы пройти квиз и увидеть рейтинг")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingPlay) {
                QuizPlayView(viewModel: viewModel)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingAdmin) {
                QuizQuestionsAdminView(viewModel: viewModel)
                    .environmentObject(authManager)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Квиз")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.minty)
            .cornerRadius(15)
        }
    }
}

// MARK: - Preview

struct QuizHomeView_Previews: PreviewProvider {
    static var previews: some View {
        QuizHomeView()
            .environmentObject(AuthManager())
    }
}

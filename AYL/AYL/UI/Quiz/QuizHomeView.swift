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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    banner
                        .padding(.horizontal, -25)
                    headerSection
                    if authManager.isParticipantLoggedIn || authManager.isAdminLoggedIn {
                        VStack(spacing: 14) {
                            actionCard(
                                title: "Пройти квиз",
                                subtitle: "Проверь себя и попади в рейтинг",
                                systemImage: "questionmark.circle.fill",
                                tint: .minty
                            ) {
                                showingPlay = true
                            }
                            actionCard(
                                title: "Рейтинг участников",
                                subtitle: "Лучшие результаты всех участников",
                                systemImage: "list.number",
                                tint: .violet
                            ) {
                                showingLeaderboard = true
                            }
                            if authManager.isAdminLoggedIn {
                                actionCard(
                                    title: "Управление вопросами",
                                    subtitle: "Добавить, изменить или удалить вопрос",
                                    systemImage: "gearshape.fill",
                                    tint: .lightBlue
                                ) {
                                    showingAdmin = true
                                }
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
                .padding(.top, 0)
                .padding(.bottom, 40)
            }
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
            .sheet(isPresented: $showingLeaderboard) {
                QuizLeaderboardView(viewModel: viewModel)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingAdmin) {
                QuizQuestionsAdminView(viewModel: viewModel)
                    .environmentObject(authManager)
            }
            .onAppear {
                viewModel.fetchQuestions()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var banner: some View {
        ZStack {
            LinearGradient(
                colors: [Color.lightBlue, Color.violet, Color.minty],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: geo.size.width * 0.8)
                        .offset(x: -geo.size.width * 0.25, y: -geo.size.height * 0.3)
                    Circle()
                        .fill(Color.minty.opacity(0.85))
                        .frame(width: geo.size.width * 0.7)
                        .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.2)
                    Circle()
                        .fill(Color.violet.opacity(0.75))
                        .frame(width: geo.size.width * 0.55)
                        .offset(x: -geo.size.width * 0.1, y: geo.size.height * 0.45)
                }
                .blur(radius: 40)
            }
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: 10)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Квиз")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
    }
    
    private func actionCard(title: String, subtitle: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint)
                        .frame(width: 52, height: 52)
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct QuizHomeView_Previews: PreviewProvider {
    static var previews: some View {
        QuizHomeView()
            .environmentObject(AuthManager())
    }
}

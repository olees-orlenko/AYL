//
//  QuizLeaderboardView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI

struct QuizLeaderboardView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: QuizViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedProfile: PublicProfile? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("QuizWallpaper")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                List {
                    if viewModel.leaderboard.isEmpty && !viewModel.isLoadingLeaderboard {
                        Text("Пока никто не проходил квиз")
                            .foregroundColor(.secondary)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, profile in
                            Button {
                                selectedProfile = profile
                            } label: {
                                leaderboardRow(place: index + 1, profile: profile)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(
                                Color(.secondarySystemBackground).opacity(0.85)
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .refreshable {
                viewModel.fetchLeaderboard()
            }
            .navigationTitle("Рейтинг участников")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .sheet(item: $selectedProfile) { profile in
                QuizParticipantProfileView(profile: profile, viewModel: viewModel)
                    .environmentObject(authManager)
            }
            .onAppear {
                viewModel.fetchLeaderboard()
            }
        }
    }
    
    // MARK: - Subviews
    
    private func leaderboardRow(place: Int, profile: PublicProfile) -> some View {
        HStack(spacing: 12) {
            placeBadge(for: place)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text(profile.role.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(profile.quizBestScore)/\(profile.quizBestTotal)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.minty)
        }
        .padding(.vertical, place <= 3 ? 6 : 4)
    }
    
    @ViewBuilder
    private func placeBadge(for place: Int) -> some View {
        if let medalColor = medalColor(for: place) {
            ZStack {
                Circle()
                    .fill(medalColor)
                    .frame(width: 30, height: 30)
                Image(systemName: "medal.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        } else {
            Text("\(place)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.violet)
                .frame(width: 30, height: 30)
        }
    }
    
    private func medalColor(for place: Int) -> Color? {
        switch place {
        case 1: return Color(red: 0.85, green: 0.65, blue: 0.13)
        case 2: return Color(red: 0.62, green: 0.65, blue: 0.68)
        case 3: return Color(red: 0.72, green: 0.45, blue: 0.20)
        default: return nil
        }
    }
}

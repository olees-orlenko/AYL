//
//  QuizParticipantProfileView.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import SwiftUI
import Kingfisher

struct QuizParticipantProfileView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var requestsViewModel = ContactRequestsViewModel()
    let profile: PublicProfile
    
    @State private var myRequest: ContactRequest?
    @State private var isLoadingRequest = true
    @State private var isSending = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                avatarSection
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.system(size: 20, weight: .semibold))
                    Text(profile.role.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("Лучший результат квиза: \(profile.quizBestScore)/\(profile.quizBestTotal)")
                    .font(.system(size: 16, weight: .medium))
                if !isMyOwnProfile {
                    contactRequestSection
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
            .onAppear {
                loadMyRequest()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var isMyOwnProfile: Bool {
        authManager.currentUserId == profile.id
    }
    
    private var avatarSection: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                if let photoUrl = profile.photoUrl, let url = URL(string: photoUrl) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var contactRequestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Контакты")
                    .font(.title3.bold())
                Rectangle()
                    .frame(width: 40, height: 3)
                    .foregroundColor(.violet)
            }
            if isLoadingRequest {
                ProgressView()
            } else if let myRequest {
                switch myRequest.status {
                case .pending:
                    Text("Запрос отправлен, ждём одобрения")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                case .approved:
                    VStack(alignment: .leading, spacing: 6) {
                        if let phone = myRequest.phone, !phone.isEmpty {
                            Text("Телефон: \(phone)")
                        }
                        if let email = myRequest.email, !email.isEmpty {
                            Text("Почта: \(email)")
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                case .declined:
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Участник отклонил запрос")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        requestButton
                    }
                }
            } else {
                requestButton
            }
        }
    }
    
    private var requestButton: some View {
        Button {
            sendRequest()
        } label: {
            Text(isSending ? "Отправляем…" : "Запросить контакты")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.minty)
                .cornerRadius(15)
        }
        .disabled(isSending)
    }
    
    // MARK: - Private methods
    
    private func loadMyRequest() {
        guard !isMyOwnProfile, let myUid = authManager.currentUserId else {
            isLoadingRequest = false
            return
        }
        requestsViewModel.fetchMyRequest(fromUid: myUid, toUid: profile.id) { request in
            myRequest = request
            isLoadingRequest = false
        }
    }
    
    private func sendRequest() {
        guard let myUid = authManager.currentUserId else { return }
        isSending = true
        requestsViewModel.sendRequest(fromUid: myUid, toUid: profile.id, toName: profile.name) { success in
            isSending = false
            if success {
                myRequest = ContactRequest(id: "", fromUid: myUid, fromName: "", toUid: profile.id, toName: profile.name, status: .pending, phone: nil, email: nil)
            }
        }
    }
}

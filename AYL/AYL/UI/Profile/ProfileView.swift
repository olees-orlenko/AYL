//
//  ProfileView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var participant: Participant?
    @State private var isLoadingProfile = false
    @State private var showingLogin = false
    @State private var showingRegister = false
    @State private var showingEdit = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            Group {
                if authManager.isAdminLoggedIn {
                    adminState
                } else if authManager.isParticipantLoggedIn {
                    participantState
                } else {
                    loggedOutState
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogin) {
                ParticipantLoginView()
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showingEdit) {
                if let participant {
                    EditProfileView(participant: participant) { updated in
                        self.participant = updated
                    }
                }
            }
            .onChange(of: authManager.currentUserId) { _, _ in
                fetchProfile()
            }
            .onChange(of: authManager.isParticipantLoggedIn) { _, _ in
                fetchProfile()
            }
            .onAppear { fetchProfile() }
        }
    }
    
    // MARK: - States
    
    private var loggedOutState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Войдите в личный кабинет, чтобы записываться на мероприятия и управлять профилем")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
            Button("Войти") { showingLogin = true }
                .buttonStyle(.borderedProminent)
            Button("Зарегистрироваться") { showingRegister = true }
                .buttonStyle(.bordered)
            Spacer()
        }
        .padding()
    }
    
    private var adminState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(.violet)
            Text("Вы вошли как администратор")
                .font(.headline)
            Button("Выйти", role: .destructive) { authManager.signOut() }
            Spacer()
        }
        .padding()
    }
    
    private var participantState: some View {
        Group {
            if isLoadingProfile {
                ProgressView()
            } else if let participant {
                List {
                    Section("Профиль") {
                        LabeledContent("Имя", value: participant.name)
                        LabeledContent("Телефон", value: participant.phone.isEmpty ? "—" : participant.phone)
                        LabeledContent("Роль", value: participant.role.displayName)
                        LabeledContent("Email", value: participant.email)
                    }
                    Section {
                        Button("Редактировать профиль") { showingEdit = true }
                    }
                    Section {
                        Button("Выйти", role: .destructive) { authManager.signOut() }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Text("Не удалось загрузить профиль")
                        .foregroundColor(.secondary)
                    Button("Повторить") { fetchProfile() }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Data
    
    private func fetchProfile() {
        guard authManager.isParticipantLoggedIn, let uid = authManager.currentUserId else {
            participant = nil
            return
        }
        isLoadingProfile = true
        db.collection("participants").document(uid).getDocument { snapshot, _ in
            isLoadingProfile = false
            guard let data = snapshot?.data() else { return }
            let timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
            participant = Participant(
                id: uid,
                name: data["name"] as? String ?? "",
                phone: data["phone"] as? String ?? "",
                role: ParticipantRole(rawValue: data["role"] as? String ?? "") ?? .alpha,
                email: data["email"] as? String ?? "",
                createdAt: timestamp.dateValue()
            )
        }
    }
}

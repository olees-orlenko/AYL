//
//  ProfileView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct ProfileView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var eventSignupManager: EventSignupManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogin = false
    @State private var showingRegister = false
    @State private var showingEdit = false
    @State private var showingAddParticipation = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @AppStorage(pushEnabledDefaultsKey) private var pushEnabled = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            bannerContent
                            paddedContent
                                .padding(.horizontal, 25)
                        }
                        .padding(.bottom, 40)
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Color.clear.frame(height: 0)
                }
            }
            .sheet(isPresented: $showingLogin) {
                ParticipantLoginView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEdit) {
                if let participant = viewModel.participant {
                    EditProfileView(viewModel: viewModel, participant: participant)
                }
            }
            .sheet(isPresented: $showingAddParticipation) {
                AddParticipationView(viewModel: viewModel)
            }
            .onChange(of: authManager.currentUserId) { _, _ in
                refresh()
            }
            .onChange(of: authManager.isParticipantLoggedIn) { _, _ in
                refresh()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                handlePhotoPicked(newItem)
            }
            .onChange(of: pushEnabled) { _, newValue in
                PushNotificationManager.shared.setPushEnabled(newValue)
            }
            .onAppear {
                refresh()
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var bannerContent: some View {
        if authManager.isAdminLoggedIn {
            profileBanner(systemImage: "checkmark.seal.fill")
        } else if authManager.isParticipantLoggedIn, let participant = viewModel.participant {
            participantBanner(participant: participant)
        } else {
            profileBanner(systemImage: "person.fill")
        }
    }
    
    private var wallpaper: some View {
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
        }
    }
    
    private var paddedContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            pushSettingsSection
            stateBody
        }
    }
    
    private var pushSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Уведомления")
                    .font(.title3.bold())
                Rectangle()
                    .frame(width: 40, height: 3)
                    .foregroundColor(.violet)
            }
            Toggle(isOn: $pushEnabled) {
                Text("Push-уведомления")
                    .font(.system(size: 16, weight: .medium))
            }
            .tint(.minty)
            Text("О новых мероприятиях и напоминания за день до начала")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Кабинет")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
    }
    
    @ViewBuilder
    private var stateBody: some View {
        if authManager.isAdminLoggedIn {
            adminBody
        } else if authManager.isParticipantLoggedIn {
            participantBody
        } else {
            loggedOutBody
        }
    }
    
    private var loggedOutBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Войдите в личный кабинет, чтобы записываться на мероприятия и управлять профилем")
                .font(.subheadline)
                .foregroundColor(.secondary)
            actionButton(title: "Войти") { showingLogin = true }
            actionButton(title: "Зарегистрироваться") { showingRegister = true }
        }
    }
    
    private var adminBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Вы вошли как администратор")
                .font(.subheadline)
                .foregroundColor(.secondary)
            actionButton(title: "Выйти", isDestructive: true) { authManager.signOut() }
        }
    }
    
    @ViewBuilder
    private var participantBody: some View {
        if viewModel.isLoadingProfile {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else if let participant = viewModel.participant {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(participant.name)
                        .font(.system(size: 20, weight: .semibold))
                    Text(participant.role.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                infoSection(participant: participant)
                upcomingSignupsSection
                participationsSection
                actionButton(title: "Редактировать профиль") { showingEdit = true }
                actionButton(title: "Выйти", isDestructive: true) { authManager.signOut() }
            }
        } else {
            VStack(spacing: 12) {
                Text("Не удалось загрузить профиль")
                    .foregroundColor(.secondary)
                actionButton(title: "Повторить") { refresh() }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
    }
    
    @ViewBuilder
    private var upcomingSignupsSection: some View {
        if !eventSignupManager.upcomingSignups.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Планирую пойти")
                        .font(.title3.bold())
                    Rectangle()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.violet)
                }
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(eventSignupManager.upcomingSignups) { signup in
                        upcomingSignupRow(signup)
                    }
                }
            }
        }
    }

    private func upcomingSignupRow(_ signup: EventSignup) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.lightBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text(signup.eventTitle)
                    .font(.system(size: 16, weight: .semibold))
                Text(signup.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                eventSignupManager.cancelSignup(newsId: signup.newsId)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var participationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Участие в мероприятиях")
                    .font(.title3.bold())
                Rectangle()
                    .frame(width: 40, height: 3)
                    .foregroundColor(.violet)
            }
            if viewModel.participations.isEmpty {
                Text("Пока нет ни одной записи")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.participations) { item in
                        participationRow(item)
                    }
                }
            }
            actionButton(title: "Добавить участие") { showingAddParticipation = true }
        }
    }
    
    // MARK: - Private methods
    
    private func profileBanner(initials: String? = nil, systemImage: String? = nil) -> some View {
        ZStack {
            wallpaper
            avatarBadge(initials: initials, systemImage: systemImage, photoUrl: nil)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    private func participantBanner(participant: Participant) -> some View {
        ZStack {
            wallpaper
            ZStack(alignment: .bottomTrailing) {
                avatarBadge(initials: initials(for: participant.name), systemImage: nil, photoUrl: participant.photoUrl)
                photoPickerButton
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.minty)
                    .frame(width: 36, height: 36)
                if isUploadingPhoto {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
        .disabled(isUploadingPhoto)
    }
    
    private func avatarBadge(initials: String?, systemImage: String?, photoUrl: String?) -> some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 140, height: 140)
            if let photoUrl, let url = URL(string: photoUrl) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
            } else if let initials, !initials.isEmpty {
                Text(initials)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            } else if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 140, height: 140)
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
    
    private func initials(for name: String) -> String {
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
    
    private func infoSection(participant: Participant) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            infoRow(title: "Телефон:", value: participant.phone.isEmpty ? "—" : participant.phone)
            infoRow(title: "Email:", value: participant.email)
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .semibold))
        }
    }
    
    private func participationRow(_ item: Participation) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.lightBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.eventTitle)
                    .font(.system(size: 16, weight: .semibold))
                Text("\(item.formattedDate) · \(item.role.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func actionButton(title: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDestructive ? .red : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDestructive ? Color.red.opacity(0.08) : Color.minty)
                .cornerRadius(15)
        }
    }
    
    private func refresh() {
        let uid = authManager.isParticipantLoggedIn ? authManager.currentUserId : nil
        viewModel.fetchProfile(uid: uid)
        viewModel.fetchParticipations(uid: uid)
        eventSignupManager.load(uid: uid)
    }
    
    private func handlePhotoPicked(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            isUploadingPhoto = true
            if let data = try? await item.loadTransferable(type: Data.self),
               let jpegData = resizedJPEGData(from: data) {
                viewModel.uploadPhoto(imageData: jpegData) { _ in
                    isUploadingPhoto = false
                }
            } else {
                isUploadingPhoto = false
            }
            selectedPhotoItem = nil
        }
    }
    
    private func resizedJPEGData(from data: Data, maxDimension: CGFloat = 640, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}

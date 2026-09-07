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
   @ObservedObject var viewModel: QuizViewModel

   @State private var myRequest: ContactRequest?
   @State private var isLoadingRequest = true
   @State private var isSending = false
   @State private var participations: [Participation] = []
   @State private var isLoadingParticipations = true

   // MARK: - Body

   var body: some View {
       NavigationStack {
           ScrollView {
               VStack(alignment: .leading, spacing: 20) {
                   banner
                       .padding(.horizontal, -25)
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
                   participationsSection
                   Spacer()
               }
               .padding(.horizontal, 25)
               .padding(.bottom, 30)
           }
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                   Button("Закрыть") { dismiss() }
               }
           }
           .onAppear {
               loadMyRequest()
               loadParticipations()
           }
       }
   }

   // MARK: - Subviews

   private var isMyOwnProfile: Bool {
       authManager.currentUserId == profile.id
   }

   private var banner: some View {
       ZStack {
           wallpaper
           avatarBadge
       }
       .frame(height: 220)
       .frame(maxWidth: .infinity)
       .clipped()
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

   private var avatarBadge: some View {
       ZStack {
           Circle()
               .fill(.ultraThinMaterial)
               .frame(width: 140, height: 140)
           if let photoUrl = profile.photoUrl, let url = URL(string: photoUrl) {
               KFImage(url)
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(width: 140, height: 140)
                   .clipShape(Circle())
           } else {
               Text(initials(for: profile.name))
                   .font(.system(size: 48, weight: .bold))
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

   @ViewBuilder
   private var participationsSection: some View {
       VStack(alignment: .leading, spacing: 12) {
           VStack(alignment: .leading, spacing: 6) {
               Text("Участие в мероприятиях")
                   .font(.title3.bold())
               Rectangle()
                   .frame(width: 40, height: 3)
                   .foregroundColor(.violet)
           }
           if isLoadingParticipations {
               ProgressView()
           } else if participations.isEmpty {
               Text("Пока нет ни одной записи")
                   .font(.subheadline)
                   .foregroundColor(.secondary)
           } else {
               VStack(alignment: .leading, spacing: 12) {
                   ForEach(participations) { item in
                       participationRow(item)
                   }
               }
           }
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
           Spacer()
       }
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

   private func loadParticipations() {
       viewModel.fetchParticipations(uid: profile.id) { items in
           participations = items
           isLoadingParticipations = false
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

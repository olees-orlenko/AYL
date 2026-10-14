//
//  EventDetailView.swift
//  AYL
//
//  Created by Олеся Орленко on 13.10.2026.
//

import SwiftUI
import Kingfisher

struct EventDetailView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: EventsViewModel
    let event: Event
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var hasParticipated: Bool? = nil
    @State private var isMarkingParticipation = false
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    @State private var fullPhoto: PhotoWrapper? = nil
    
    private var canEdit: Bool {
        authManager.isParticipantLoggedIn || authManager.isAdminLoggedIn
    }
    
    private var canDelete: Bool {
        authManager.isAdminLoggedIn || event.authorUid == authManager.currentUserId
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerImage
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    infoSection
                    participationButton
                    participantsSection
                    photosSection
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingEdit) {
            EventFormView(viewModel: viewModel, existingEvent: event)
        }
        .fullScreenCover(item: $fullPhoto) { wrapper in
            ZStack {
                Color.black.ignoresSafeArea()
                if let url = URL(string: wrapper.url) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                }
            }
            .onTapGesture { fullPhoto = nil }
        }
        .alert("Удалить мероприятие?", isPresented: $showingDeleteConfirmation) {
            Button("Отмена", role: .cancel) {}
            Button("Удалить", role: .destructive) {
                viewModel.deleteEvent(event) { success in
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Это действие нельзя отменить.")
        }
        .onAppear {
            viewModel.checkParticipated(in: event, uid: authManager.currentUserId) { result in
                hasParticipated = result
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerImage: some View {
        Group {
            if let imageUrl = event.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder { placeholderView }
                    .fade(duration: 0.3)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .clipped()
    }
    
    private var placeholderView: some View {
        ZStack(alignment: .top) {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 90)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.displayTitle.uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Rectangle()
                .frame(width: 60, height: 4)
                .foregroundColor(.violet)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "calendar")
                Text(event.formattedDate)
            }
            HStack {
                Image(systemName: "mappin.circle")
                Text(event.city)
            }
            HStack {
                Image(systemName: "tag")
                Text(event.type.displayName)
            }
        }
        .font(.subheadline)
        .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private var participationButton: some View {
        if authManager.isParticipantLoggedIn {
            Button {
                markParticipated()
            } label: {
                Group {
                    if let participated = hasParticipated {
                        HStack(spacing: 6) {
                            Image(systemName: participated ? "checkmark.circle.fill" : "person.badge.plus")
                            Text(participated ? "Отмечено в профиле" : "Я тоже участвовал")
                        }
                        .foregroundColor(participated ? .minty : .white)
                    } else {
                        ProgressView()
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(15)
            }
            .disabled(hasParticipated != false || isMarkingParticipation)
            .animation(.easeInOut(duration: 0.25), value: hasParticipated)
        }
    }
    
    private var backgroundColor: Color {
        switch hasParticipated {
        case .some(true): return Color.minty.opacity(0.12)
        case .some(false): return Color.minty
        case nil: return Color.gray.opacity(0.12)
        }
    }
    
    @ViewBuilder
    private var participantsSection: some View {
        if !event.participantRows.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Участники")
                        .font(.title3.bold())
                    Rectangle()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.violet)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(event.participantRows, id: \.label) { row in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(row.value)
                                .font(.system(size: 15))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var photosSection: some View {
        if !event.photoUrls.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Фотографии")
                        .font(.title3.bold())
                    Rectangle()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.violet)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(event.photoUrls, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    KFImage(url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                )
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture { fullPhoto = PhotoWrapper(url: urlString) }
                        }
                    }
                }
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if canEdit {
                    Button { showingEdit = true } label: {
                        Image(systemName: "pencil")
                    }
                }
                if canDelete {
                    Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func markParticipated() {
        guard let uid = authManager.currentUserId else { return }
        isMarkingParticipation = true
        viewModel.markParticipated(in: event, uid: uid) { success in
            isMarkingParticipation = false
            if success { hasParticipated = true }
        }
    }
}

private struct PhotoWrapper: Identifiable {
    let id = UUID()
    let url: String
}

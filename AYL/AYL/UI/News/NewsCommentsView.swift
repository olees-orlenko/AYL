//
//  NewsCommentsView.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import SwiftUI

struct NewsCommentsView: View {
    
    // MARK: - Properties
    
    let newsId: String
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = NewsCommentsViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var newCommentText = ""
    @State private var showingReportConfirmation = false
    @FocusState private var isInputFocused: Bool
    
    private var visibleComments: [NewsComment] {
        viewModel.comments.filter { !viewModel.blockedUserIds.contains($0.authorUid) }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("QuizWallpaper")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    List {
                        ForEach(visibleComments) { comment in
                            commentRow(comment)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .onAppear {
                                    viewModel.loadNextPageIfNeeded(currentComment: comment, newsId: newsId)
                                }
                        }
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .overlay {
                        if viewModel.isLoading && viewModel.comments.isEmpty {
                            ProgressView()
                        } else if viewModel.comments.isEmpty && !viewModel.isLoading {
                            emptyState
                        }
                    }
                    inputBar
                }
            }
            .navigationTitle("Комментарии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                viewModel.loadFirstPage(newsId: newsId)
                viewModel.loadBlockedUsers(currentUid: authManager.currentUserId)
            }
            .alert("Жалоба отправлена", isPresented: $showingReportConfirmation) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text("Спасибо, мы проверим этот комментарий.")
            }
        }
    }
    
    // MARK: - EmptyState
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("Комментариев пока нет — будьте первым!")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Row
    
    private func commentRow(_ comment: NewsComment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.subheadline.bold())
                    .foregroundColor(.minty)
                Spacer()
                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        .swipeActions(edge: .trailing) {
            if authManager.isAdminLoggedIn || comment.authorUid == authManager.currentUserId {
                Button(role: .destructive) {
                    viewModel.deleteComment(comment, newsId: newsId)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
            if comment.authorUid != authManager.currentUserId {
                Button {
                    report(comment)
                } label: {
                    Label("Пожаловаться", systemImage: "flag")
                }
                .tint(.orange)
                Button {
                    viewModel.blockUser(uid: comment.authorUid, name: comment.authorName, currentUid: authManager.currentUserId)
                } label: {
                    Label("Заблокировать", systemImage: "person.fill.xmark")
                }
                .tint(.red)
            }
        }
    }
    
    private func report(_ comment: NewsComment) {
        guard let uid = authManager.currentUserId else { return }
        viewModel.reportComment(comment, newsId: newsId, reportedByUid: uid) { success in
            if success {
                showingReportConfirmation = true
            }
        }
    }
    
    // MARK: - Input
    
    @ViewBuilder
    private var inputBar: some View {
        if authManager.isParticipantLoggedIn || authManager.isAdminLoggedIn {
            HStack(spacing: 8) {
                TextField("Ваш комментарий...", text: $newCommentText, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(14)
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(isCommentValid ? Color.minty : Color.gray.opacity(0.3))
                        .cornerRadius(14)
                }
                .disabled(!isCommentValid || viewModel.isSending)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        } else {
            Text("Войдите в личный кабинет, чтобы оставить комментарий")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
    }
    
    private var isCommentValid: Bool {
        !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func send() {
        guard let uid = authManager.currentUserId else { return }
        isInputFocused = false
        viewModel.addComment(newsId: newsId, authorUid: uid, text: newCommentText) { success in
            if success {
                newCommentText = ""
            }
        }
    }
}

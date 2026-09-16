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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.comments) { comment in
                    commentRow(comment)
                        .onAppear {
                            viewModel.loadNextPageIfNeeded(currentComment: comment, newsId: newsId)
                        }
                }
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                if viewModel.comments.isEmpty && !viewModel.isLoading {
                    Text("Комментариев пока нет — будьте первым!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .overlay {
                if viewModel.isLoading && viewModel.comments.isEmpty {
                    ProgressView()
                }
            }
            .navigationTitle("Комментарии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                inputBar
            }
            .onAppear {
                viewModel.loadFirstPage(newsId: newsId)
            }
            .alert("Жалоба отправлена", isPresented: $showingReportConfirmation) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text("Спасибо, мы проверим этот комментарий.")
            }
        }
    }
    
    // MARK: - Row
    
    private func commentRow(_ comment: NewsComment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.subheadline.bold())
                Spacer()
                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
        }
        .padding(.vertical, 4)
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
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Ваш комментарий...", text: $newCommentText, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                }
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding()
            .background(.bar)
        } else {
            Text("Войдите в личный кабинет, чтобы оставить комментарий")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
        }
    }
    
    private func send() {
        guard let uid = authManager.currentUserId else { return }
        viewModel.addComment(newsId: newsId, authorUid: uid, text: newCommentText) { success in
            if success {
                newCommentText = ""
            }
        }
    }
}

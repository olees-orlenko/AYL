//
//  CommentReportsAdminView.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import SwiftUI

struct CommentReportsAdminView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CommentReportsAdminViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.reports.isEmpty {
                    ProgressView()
                } else if viewModel.reports.isEmpty {
                    Text("Жалоб нет")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.reports) { report in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(report.commentText)
                                    .font(.body)
                                Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Button("Удалить комментарий", role: .destructive) {
                                        viewModel.deleteCommentAndDismiss(report)
                                    }
                                    .font(.caption)
                                    .buttonStyle(.borderless)
                                    Spacer()
                                    Button("Оставить, закрыть жалобу") {
                                        viewModel.dismissReport(report)
                                    }
                                    .font(.caption)
                                    .buttonStyle(.borderless)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Жалобы на комментарии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                viewModel.fetchReports()
            }
        }
    }
}

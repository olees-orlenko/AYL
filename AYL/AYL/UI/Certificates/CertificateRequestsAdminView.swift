//
//  CertificateRequestsAdminView.swift
//  AYL
//
//  Created by Олеся Орленко on 09.09.2026.
//

import SwiftUI

struct CertificateRequestsAdminView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CertificateRequestsViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.pendingRequests.isEmpty && !viewModel.isLoadingPending {
                    Text("Нет заявок на сертификаты")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.pendingRequests) { request in
                        requestRow(request)
                    }
                }
            }
            .refreshable {
                viewModel.fetchPendingRequests()
            }
            .navigationTitle("Запросы на сертификаты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                viewModel.fetchPendingRequests()
            }
        }
    }
    
    // MARK: - Subviews
    
    private func requestRow(_ request: CertificateRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.participantName)
                .font(.system(size: 16, weight: .semibold))
            Text(request.eventTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(request.formattedEventDate)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 10) {
                Button {
                    viewModel.approveRequest(id: request.id)
                } label: {
                    Text("Одобрить")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.minty)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                Button {
                    viewModel.declineRequest(id: request.id)
                } label: {
                    Text("Отклонить")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

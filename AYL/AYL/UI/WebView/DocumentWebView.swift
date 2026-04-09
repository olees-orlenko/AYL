//
//  DocumentWebView.swift
//  AYL
//
//  Created by Олеся Орленко on 06.04.2026.
//

import SwiftUI
import WebKit

struct DocumentWebView: View {
    
    // MARK: - Properties
    
    let urlString: String
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    // MARK: - Body
    
    var body: some View {
        ZStack {
            WebViewContainer(urlString: urlString, isLoading: $isLoading, errorMessage: $errorMessage)
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Не удалось загрузить страницу")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Повторить") {
                        self.errorMessage = nil
                        self.isLoading = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Preview

struct DocumentWebView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentWebView(urlString: "https://ayl.ru/dokumenty")
    }
}

//
//  NewsView.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import SwiftUI

struct NewsView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel = NewsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAddSheet = false
    @State private var selectedNews: NewsItem? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        if viewModel.isLoading && viewModel.news.isEmpty {
                            loadingPlaceholder
                        } else if viewModel.news.isEmpty {
                            VStack {
                                Spacer()
                                emptyState
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            newsList
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                if viewModel.isLoading && !viewModel.news.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                adminToolbar
            }
            .sheet(isPresented: $showingAddSheet) {
                AddNewsView(viewModel: viewModel)
            }
            .onAppear { viewModel.fetchData() }
            .sheet(item: $selectedNews) { news in
                EditNewsView(viewModel: viewModel, newsItem: news)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Новости")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var newsList: some View {
        ForEach(viewModel.news) { item in
            NavigationLink(destination: NewsDetailView(news: item)) {
                NewsCard(news: item)
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                if authManager.isAdminLoggedIn {
                    Button {
                        selectedNews = item
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        viewModel.deleteNews(id: item.id)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        Text("Новостей пока нет")
            .foregroundColor(.gray)
            .font(.system(size: 14, weight: .semibold))
        
    }
    
    private var loadingPlaceholder: some View {
        VStack {
            Spacer(minLength: 100)
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ToolbarContentBuilder
    private var adminToolbar: some ToolbarContent {
        if authManager.isAdminLoggedIn {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Выйти") { authManager.signOut() }
            }
        }
    }
}

// MARK: - Preview

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}

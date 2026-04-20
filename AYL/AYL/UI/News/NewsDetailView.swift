//
//  NewsDetailView.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI

struct NewsDetailView: View {
    
    // MARK: - Properties
    
    let news: NewsItem
    @Environment(\.dismiss) var dismiss

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerImage
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    dateSection
                    contentSection
                    if !news.linkUrl.isEmpty {
                        footerSection
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    
    private var headerImage: some View {
        AsyncImage(url: URL(string: news.imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .clipped()
            case .failure(_), .empty:
                placeholderView
            @unknown default:
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(news.title.uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Rectangle()
                .frame(width: 60, height: 4)
                .foregroundColor(.violet)
        }
    }
    
    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.caption)
            Text(news.formattedDate)
                .font(.subheadline)
        }
        .foregroundColor(.gray)
    }
    
    private var contentSection: some View {
        Text(news.content)
            .font(.body)
            .lineSpacing(4)
            .foregroundColor(.primary)
    }
    
    private var footerSection: some View {
        HStack {
            Button(action: {
                if let url = URL(string: news.linkUrl) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Text("Подробнее")
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.violet)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.violet.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
    }
}

// MARK: - Preview

struct NewsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NewsDetailView(news: NewsItem(
            id: "1",
            title: "Осенняя конференция в Краснодаре",
            content: "Пятидневный межрегиональный тренинг подошёл к концу, но это точно не повод грустить!\n\nУчастники провели насыщенные дни, прокачали лидерские и коммуникативные навыки, нашли новых друзей и зарядились нашей атмосферой.",
            imageUrl: "https://optim.tildacdn.com/tild3834-3237-4363-b633-343635326138/-/resize/580x/-/format/webp/photo_2025-11-09_080.jpeg.webp",
            date: Date(),
            linkUrl: "https://t.me/aylrus"
        ))
    }
}

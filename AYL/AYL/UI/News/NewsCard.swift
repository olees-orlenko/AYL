//
//  NewsCard.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI

struct NewsCard: View {
    
    // MARK: - Properties
    
    let news: NewsItem
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            imageSection
            textSection
            footerSection
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Subviews
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: news.imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            case .failure(_), .empty:
                placeholderView
            @unknown default:
                placeholderView
            }
        }
        .cornerRadius(15)
    }
    
    private var placeholderView: some View {
        ZStack {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(news.title.uppercased())
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .foregroundColor(.black)
            Text(news.content)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding(.horizontal, 2)
    }
    
    private var footerSection: some View {
        HStack {
            Text(news.formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.violet)
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview

struct NewsCard_Previews: PreviewProvider {
    static var previews: some View {
        NewsCard(news: NewsItem(
            id: "1",
            title: "Осенняя конференция",
            content: "Пятидневный межрегиональный тренинг подошёл к концу, но это точно не повод грустить! Участники провели насыщенные дни, прокачали лидерские и коммуникативные навыки, нашли новых друзей и зарядились нашей атмосферой.",
            imageUrl: "https://optim.tildacdn.com/tild3834-3237-4363-b633-343635326138/-/resize/580x/-/format/webp/photo_2025-11-09_080.jpeg.webp",
            date: Date(),
            linkUrl: "https://t.me/aylrus"
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

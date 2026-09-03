//
//  NewsDetailView.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import SwiftUI
import Kingfisher

struct NewsDetailView: View {
    
    // MARK: - Properties
    
    let news: NewsItem
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var eventSignupManager: EventSignupManager
    @State private var isTogglingSignup = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerImage
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    dateSection
                    signupSection
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
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
    }
    
    // MARK: - Subviews
    
    private var headerImage: some View {
        KFImage(URL(string: news.imageUrl))
            .placeholder {
                placeholderView
            }
            .fade(duration: 0.3)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .clipped()
    }
    
    private var placeholderView: some View {
        ZStack {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .padding(.top, 60)
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(news.formattedDate)
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
            if news.isEvent, let formattedEventDate = news.formattedEventDate {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                    Text("Мероприятие: \(formattedEventDate)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.violet)
            }
        }
    }
    
    private var contentSection: some View {
        Text(news.content)
            .font(.body)
            .lineSpacing(4)
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var signupSection: some View {
        if news.isEvent, authManager.isParticipantLoggedIn, let eventDate = news.eventDate, eventDate > Date() {
            let isSignedUp = eventSignupManager.isSignedUp(newsId: news.id)
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    toggleSignup(eventDate: eventDate)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isSignedUp ? "checkmark.circle.fill" : "person.badge.plus")
                        Text(isSignedUp ? "Мероприятие добавлено — отменить" : "Я тоже иду")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSignedUp ? .minty : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSignedUp ? Color.minty.opacity(0.12) : Color.minty)
                    .cornerRadius(15)
                }
                .disabled(isTogglingSignup)
                Text(news.linkUrl.isEmpty
                     ? "Это личная пометка в приложении, а не официальная запись"
                     : "Это личная пометка в приложении. Чтобы попасть на мероприятие, обязательно заполните форму по ссылке ниже («Подробнее»)")
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func toggleSignup(eventDate: Date) {
        isTogglingSignup = true
        eventSignupManager.toggleSignup(newsId: news.id, eventTitle: news.title, eventDate: eventDate) { _ in
            isTogglingSignup = false
        }
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
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
        }
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

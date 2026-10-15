//
//  EventCard.swift
//  AYL
//
//  Created by Олеся Орленко on 15.10.2026.
//

import SwiftUI
import Kingfisher

struct EventCard: View {
    
    // MARK: - Properties
    
    let event: Event
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            imageSection
            textSection
            footerSection
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
    
    // MARK: - Subviews
    
    private var imageSection: some View {
        Group {
            if let urlString = event.imageUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder { placeholderView }
                    .fade(duration: 0.3)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(height: 200)
        .clipped()
        .cornerRadius(15)
    }
    
    private var placeholderView: some View {
        ZStack {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.displayTitle.uppercased())
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .foregroundColor(.primary)
            Text(event.city)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 2)
    }
    
    private var footerSection: some View {
        HStack {
            Text(event.formattedDate)
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

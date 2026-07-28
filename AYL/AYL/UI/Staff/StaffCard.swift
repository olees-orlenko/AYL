//
//  StaffCard.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import SwiftUI
import Kingfisher

struct StaffCard: View {
    
    // MARK: - Properties
    
    let member: StaffMember
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            memberImage
            memberInfoSection
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(15)
    }
    
    // MARK: - Subviews
    
    private var memberImage: some View {
        KFImage(URL(string: member.photoName))
            .placeholder {
                placeholderImage
            }
            .fade(duration: 0.3)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().inset(by: 1).stroke(Color.minty.opacity(0.5), lineWidth: 2))
    }
    
    private var placeholderImage: some View {
        Image("ayl_logo_1")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(10)
    }
    
    private var memberInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            nameAndSocialHeader
            Text(member.position)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
            Text(member.bio)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var nameAndSocialHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(member.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            telegramLinkButton
        }
    }
    
    @ViewBuilder
    private var telegramLinkButton: some View {
        if let telegramLink = member.telegramLink,
           let url = URL(string: telegramLink) {
            Link(destination: url) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.lightBlue)
            }
        }
    }
}

// MARK: - Preview

struct StaffCard_Previews: PreviewProvider {
    static var previews: some View {
        StaffCard(member: StaffMember(
            id: "preview_id",
            name: "Алёна",
            position: "Исполнительный директор",
            bio: "Алёна руководит",
            photoName: "staff_photo",
            telegramLink: "https://t.me/alena"
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

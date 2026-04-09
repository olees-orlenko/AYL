//
//  GalleryView.swift
//  AYL
//
//  Created by Олеся Орленко on 08.04.2026.
//

import SwiftUI

struct GalleryView: View {
    
    // MARK: - Properties
    
    private var groupedPhotos: [String: [GalleryItem]] {
        Dictionary(grouping: GalleryItem.mockPhotos, by: { $0.title })
    }
    private var sortedTitles: [String] {
        groupedPhotos.keys.sorted()
    }
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    @State private var selectedPhoto: GalleryItem? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    headerSection
                    ForEach(sortedTitles, id: \.self) { title in
                        VStack(alignment: .leading, spacing: 15) {
                            sectionHeader(title: title)
                            LazyVGrid(columns: columns, spacing: 15) {
                                if let photosInGroup = groupedPhotos[title] {
                                    ForEach(photosInGroup) { photo in
                                        galleryCard(photo)
                                            .onTapGesture {
                                                selectedPhoto = photo
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $selectedPhoto) { photo in
                if let currentGroup = groupedPhotos[photo.title] {
                    FullScreenImageView(
                        groupPhotos: currentGroup,
                        selectedPhotoID: photo.id
                    )
                } else {
                    FullScreenImageView(
                        groupPhotos: [photo],
                        selectedPhotoID: photo.id
                    )
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Галерея")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private func sectionHeader(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    private func galleryCard(_ photo: GalleryItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let uiImage = UIImage(named: photo.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("ayl_logo_1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .background(Color.white)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 180)
            .background(Color.white)
            .clipped()
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}

// MARK: - Preview

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}

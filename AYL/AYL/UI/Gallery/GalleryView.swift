//
//  GalleryView.swift
//  AYL
//
//  Created by Олеся Орленко on 08.04.2026.
//

import SwiftUI

struct GalleryView: View {
    
    // MARK: - Properties
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    @State private var selectedPhoto: GalleryItem? = nil
    @State private var showingAddSheet = false
    @StateObject var viewModel = GalleryViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headerSection
                            if viewModel.photos.isEmpty && !viewModel.isLoading {
                                VStack {
                                    Spacer()
                                    emptySectionHeader
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(viewModel.sortedTitles, id: \.self) { title in
                                    VStack(alignment: .leading, spacing: 15) {
                                        sectionHeader(title: title)
                                        LazyVGrid(columns: columns, spacing: 15) {
                                            if let photosInGroup = viewModel.groupedPhotos[title] {
                                                ForEach(photosInGroup) { photo in
                                                    galleryCard(photo)
                                                        .onTapGesture {
                                                            selectedPhoto = photo
                                                        }
                                                        .contextMenu {
                                                            if authManager.isAdminLoggedIn {
                                                                Button(role: .destructive) {
                                                                    viewModel.deletePhoto(id: photo.id)
                                                                } label: {
                                                                    Label("Удалить", systemImage: "trash")
                                                                }
                                                            }
                                                        }
                                                }
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
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                        Button("Выйти") {
                            authManager.signOut()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGalleryPhotoView(viewModel: viewModel)
            }
            .fullScreenCover(item: $selectedPhoto) { photo in
                if let currentGroup = viewModel.groupedPhotos[photo.title] {
                    FullScreenImageView(
                        groupPhotos: currentGroup,
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
    
    private var emptySectionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("В галерее пока нет фото")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    private func galleryCard(_ photo: GalleryItem) -> some View {
        ZStack {
            let urlString = photo.imageName.trimmingCharacters(in: .whitespacesAndNewlines)
            return ZStack {
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                    case .failure(let error):
                        let _ = print("Ошибка загрузки фото: \(error.localizedDescription) для URL: \(photo.imageName)")
                        placeholderView
                    case .empty:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Image("ayl_logo_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }
}

// MARK: - Preview

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}

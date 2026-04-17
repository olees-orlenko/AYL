//
//  FullScreenImageView.swift
//  AYL
//
//  Created by Олеся Орленко on 08.04.2026.
//

import SwiftUI

struct FullScreenImageView: View {
    
    // MARK: - Properties
    
    let groupPhotos: [GalleryItem]
    @State var selectedPhotoID: String
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Init
    
    init(groupPhotos: [GalleryItem], selectedPhotoID: String) {
        self.groupPhotos = groupPhotos
        _selectedPhotoID = State(initialValue: selectedPhotoID)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedPhotoID) {
                ForEach(groupPhotos, id: \.id) { photo in
                    ZoomableImagePage(photo: photo)
                        .tag(photo.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            closeButton
        }
    }
    
    // MARK: - Subviews
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.lightBlue)
                .padding(.top, 50)
                .padding(.trailing, 20)
        }
    }
}

//
//  ZoomableImagePage.swift
//  AYL
//
//  Created by Олеся Орленко on 09.04.2026.
//

import SwiftUI

struct ZoomableImagePage: View {
    
    // MARK: - Properties
    
    let photo: GalleryItem
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            imageLayer
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .gesture(zoomGesture)
                .simultaneousGesture(scale > 1.0 ? dragGesture : nil)
                .onTapGesture(count: 2) {
                    resetImageState()
                }
        }
    }
    
    // MARK: - Subviews
    
    private var imageLayer: some View {
        let urlString = photo.imageName.trimmingCharacters(in: .whitespacesAndNewlines)
        return Group {
            if let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        let _ = print("Ошибка загрузки: \(error.localizedDescription) для \(urlString)")
                        placeholderView
                    case .empty:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
                .id(photo.id)
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.white
            ProgressView()
                .scaleEffect(1.5)
                .offset(y: -40)
            Image("ayl_logo_1")
                .resizable()
                .scaledToFit()
                .padding(100)
                .opacity(0.3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Gestures
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1.0), 5.0)
            }
            .onEnded { _ in lastScale = 1.0 }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }
    
    // MARK: - Private Methods
    
    private func resetImageState() {
        withAnimation(.spring()) {
            if scale > 1.0 {
                scale = 1.0
                offset = .zero
                lastOffset = .zero
            } else {
                scale = 2.0
            }
        }
    }
}

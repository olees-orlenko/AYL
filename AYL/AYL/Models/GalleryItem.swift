//
//  GalleryItem.swift
//  AYL
//
//  Created by Олеся Орленко on 08.04.2026.
//

import Foundation

struct GalleryItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

extension GalleryItem {
    static let mockPhotos: [GalleryItem] = [
        GalleryItem(imageName: "photo1", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo2", title: "Тренинг"),
        GalleryItem(imageName: "photo1", title: "Веревочный курс"),
        GalleryItem(imageName: "photo2", title: "Наши участники"),
        GalleryItem(imageName: "photo1", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo", title: "Тренинг")
    ]
}

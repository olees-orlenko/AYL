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
        GalleryItem(imageName: "photo2", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo3", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo4", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo5", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo6", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo7", title: "Веревочный курс"),
        GalleryItem(imageName: "photo8", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo9", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo10", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo11", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo12", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo13", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo14", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo15", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo16", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo17", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo18", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo19", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo20", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo21", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo22", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo23", title: "Конференция АЮЛ"),
        GalleryItem(imageName: "photo24", title: "Веревочный курс"),
        GalleryItem(imageName: "photo25", title: "Веревочный курс"),
        GalleryItem(imageName: "photo26", title: "Веревочный курс")
    ]
}

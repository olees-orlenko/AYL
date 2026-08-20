//
//  NewsItem.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import Foundation

struct NewsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let imageUrl: String
    let date: Date
    let linkUrl: String
    let isEvent: Bool
    let eventDate: Date?

    init(id: String, title: String, content: String, imageUrl: String, date: Date, linkUrl: String, isEvent: Bool = false, eventDate: Date? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.date = date
        self.linkUrl = linkUrl
        self.isEvent = isEvent
        self.eventDate = eventDate
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var formattedEventDate: String? {
        guard let eventDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: eventDate)
    }
}

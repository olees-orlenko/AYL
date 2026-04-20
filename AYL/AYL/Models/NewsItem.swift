//
//  NewsItem.swift
//  AYL
//
//  Created by Олеся Орленко on 20.04.2026.
//

import Foundation

struct NewsItem: Identifiable {
    let id: String
    let title: String
    let content: String
    let imageUrl: String
    let date: Date
    let linkUrl: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

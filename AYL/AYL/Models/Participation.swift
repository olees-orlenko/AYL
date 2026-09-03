//
//  Participation.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import Foundation

struct Participation: Identifiable {
    let id: String
    let eventTitle: String
    let eventDate: Date
    let role: ParticipantRole
    let newsId: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: eventDate)
    }
}

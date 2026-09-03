//
//  EventSignup.swift
//  AYL
//
//  Created by Олеся Орленко on 03.09.2026.
//

import Foundation

struct EventSignup: Identifiable {
    let id: String
    let newsId: String
    let eventTitle: String
    let eventDate: Date
    let role: ParticipantRole

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: eventDate)
    }
}

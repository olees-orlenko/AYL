//
//  Event.swift
//  AYL
//
//  Created by Олеся Орленко on 13.10.2026.
//

import Foundation

enum EventType: String, Codable, CaseIterable, Identifiable {
    case conference
    case training
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .conference: return "Конференция"
        case .training: return "Тренинг"
        }
    }
}

struct Event: Identifiable, Hashable {
    let id: String
    let type: EventType
    let title: String
    let city: String
    let eventDate: Date
    let imageUrl: String?
    let directorName: String
    let executiveDirectorName: String
    let adminTeamNames: String
    let gammaNames: String
    let facilitatorNames: String
    let delegateNames: String
    let photoUrls: [String]
    let authorUid: String
    let createdAt: Date
    
    init(
        id: String,
        type: EventType,
        title: String,
        city: String,
        eventDate: Date,
        imageUrl: String? = nil,
        directorName: String = "",
        executiveDirectorName: String = "",
        adminTeamNames: String = "",
        gammaNames: String = "",
        facilitatorNames: String = "",
        delegateNames: String = "",
        photoUrls: [String] = [],
        authorUid: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.city = city
        self.eventDate = eventDate
        self.imageUrl = imageUrl
        self.directorName = directorName
        self.executiveDirectorName = executiveDirectorName
        self.adminTeamNames = adminTeamNames
        self.gammaNames = gammaNames
        self.facilitatorNames = facilitatorNames
        self.delegateNames = delegateNames
        self.photoUrls = photoUrls
        self.authorUid = authorUid
        self.createdAt = createdAt
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: eventDate)
    }
    
    var displayTitle: String {
        title.trimmingCharacters(in: .whitespaces).isEmpty
        ? "\(type.displayName) — \(city)"
        : title
    }
    
    var participantRows: [(label: String, value: String)] {
        [
            ("Директор", directorName),
            ("Исполнительный директор", executiveDirectorName),
            ("Административная команда", adminTeamNames),
            ("Гамма", gammaNames),
            ("Ведущие", facilitatorNames),
            ("Делегаты", delegateNames)
        ].filter { !$0.value.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

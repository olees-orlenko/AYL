//
//  Participant.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import Foundation

enum ParticipantRole: String, CaseIterable, Identifiable, Codable {
    case unspecified
    case alpha
    case beta
    case gamma
    case director
    case graduate

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .unspecified: return ""
        case .alpha: return "α"
        case .beta: return "β"
        case .gamma: return "γ"
        case .director: return "ИД"
        case .graduate: return ""
        }
    }

    var title: String {
        switch self {
        case .unspecified: return "Гость"
        case .alpha: return "Альфа (делегат)"
        case .beta: return "Бета (ведущий)"
        case .gamma: return "Гамма (программный координатор)"
        case .director: return "Исполнительный директор"
        case .graduate: return "Выпускник"
        }
    }

    var displayName: String {
        symbol.isEmpty ? title : "\(symbol) — \(title)"
    }
}

struct Participant: Identifiable {
    let id: String
    let name: String
    let phone: String
    let role: ParticipantRole
    let email: String
    let createdAt: Date
    let photoUrl: String?
    let blockedUsers: [String: String]
    var personalDataConsentAt: Date?
    var marketingPushConsent: Bool
    var marketingPushConsentAt: Date?

    init(
        id: String,
        name: String,
        phone: String,
        role: ParticipantRole,
        email: String,
        createdAt: Date,
        photoUrl: String? = nil,
        blockedUsers: [String: String] = [:],
        personalDataConsentAt: Date? = nil,
        marketingPushConsent: Bool = false,
        marketingPushConsentAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.role = role
        self.email = email
        self.createdAt = createdAt
        self.photoUrl = photoUrl
        self.blockedUsers = blockedUsers
        self.personalDataConsentAt = personalDataConsentAt
        self.marketingPushConsent = marketingPushConsent
        self.marketingPushConsentAt = marketingPushConsentAt
    }
}

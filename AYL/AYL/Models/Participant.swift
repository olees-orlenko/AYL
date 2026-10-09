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
    case eventDirector
    case adminTeam
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .unspecified: return ""
        case .alpha: return "α"
        case .beta: return "β"
        case .gamma: return "γ"
        case .director: return "ИД"
        case .graduate: return ""
        case .eventDirector: return ""
        case .adminTeam: return "АК"
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
        case .eventDirector: return "Директор"
        case .adminTeam: return "Административная команда"
        }
    }
    
    var displayName: String {
        symbol.isEmpty ? title : "\(symbol) — \(title)"
    }
    
    static var participationRoles: [ParticipantRole] {
        allCases.filter { $0 != .graduate }
    }
    
    static var profileRoles: [ParticipantRole] {
        allCases.filter { $0 != .adminTeam && $0 != .eventDirector }
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
    let birthDate: Date?
    let legalRepresentativeConsentAt: Date?
    
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
        marketingPushConsentAt: Date? = nil,
        birthDate: Date? = nil,
        legalRepresentativeConsentAt: Date? = nil
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
        self.birthDate = birthDate
        self.legalRepresentativeConsentAt = legalRepresentativeConsentAt
    }
}

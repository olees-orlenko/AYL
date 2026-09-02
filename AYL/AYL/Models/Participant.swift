//
//  Participant.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import Foundation

enum ParticipantRole: String, CaseIterable, Identifiable, Codable {
    case alpha
    case beta
    case gamma
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .alpha: return "α"
        case .beta: return "β"
        case .gamma: return "γ"
        }
    }
    
    var title: String {
        switch self {
        case .alpha: return "Альфа (делегат)"
        case .beta: return "Бета (ведущий)"
        case .gamma: return "Гамма (программный координатор)"
        }
    }
    
    var displayName: String { "\(symbol) — \(title)" }
}

struct Participant: Identifiable {
    let id: String
    let name: String
    let phone: String
    let role: ParticipantRole
    let email: String
    let createdAt: Date
    
    init(id: String, name: String, phone: String, role: ParticipantRole, email: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.phone = phone
        self.role = role
        self.email = email
        self.createdAt = createdAt
    }
}

//
//  CertificateRequest.swift
//  AYL
//
//  Created by Олеся Орленко on 09.09.2026.
//

import Foundation

enum CertificateStatus: String {
    case pending
    case approved
    case declined
}

struct CertificateRequest: Identifiable {
    let id: String
    let participantUid: String
    let participantName: String
    let newsId: String
    let eventTitle: String
    let eventDate: Date
    let status: CertificateStatus
    
    var formattedEventDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: eventDate)
    }
}

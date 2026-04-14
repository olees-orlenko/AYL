//
//  StaffMember.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import Foundation

struct StaffMember: Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let bio: String
    let photoName: String
    let telegramLink: String?
}

extension StaffMember {
    static let mockStaff: [StaffMember] = [
        StaffMember(
            name: "Алёна Коваленко",
            position: "Исполнительный директор",
            bio: "Алёна руководит стратегическим развитием АЮЛ, вдохновляя команду на новые достижения и поддерживая инициативы молодежи.",
            photoName: "staff_photo",
            telegramLink: "https://t.me/alena_vesna_tattoo"
        ),
        StaffMember(
            name: "Алёна Коваленко",
            position: "Исполнительный директор",
            bio: "Алёна руководит стратегическим развитием АЮЛ, вдохновляя команду на новые достижения и поддерживая инициативы молодежи.",
            photoName: "staff_photo",
            telegramLink: "https://t.me/alena_vesna_tattoo"
        ),
        StaffMember(
            name: "Алёна Коваленко",
            position: "Исполнительный директор",
            bio: "Алёна руководит стратегическим развитием АЮЛ, вдохновляя команду на новые достижения и поддерживая инициативы молодежи.",
            photoName: "staff_photo",
            telegramLink: "https://t.me/alena_vesna_tattoo"
        )
    ]
}

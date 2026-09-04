//
//  ContactsInfo.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import Foundation

struct ContactsInfo {
    var website: String
    var email: String
    var phone: String
    var telegram: String
    var vk: String
    var youtube: String
    var directorTitle: String
    var directorName: String
    
    static let `default` = ContactsInfo(
        website: "https://ayl.ru",
        email: "info@ayl.ru",
        phone: "+7 (910) 260-58-29",
        telegram: "https://t.me/aylrus",
        vk: "https://vk.com/aylrussia",
        youtube: "https://www.youtube.com/@AYL_Russia",
        directorTitle: "Исполнительный директор",
        directorName: "Алёна Коваленко"
    )
    
    var websiteDisplay: String {
        website
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    var emailURL: String { "mailto:\(email)" }
    
    var phoneURL: String {
        "tel:" + phone.filter { $0.isNumber || $0 == "+" }
    }
}

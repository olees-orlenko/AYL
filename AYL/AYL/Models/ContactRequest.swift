//
//  ContactRequest.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import Foundation

enum ContactRequestStatus: String {
    case pending
    case approved
    case declined
}

struct ContactRequest: Identifiable {
    var id: String
    let fromUid: String
    let fromName: String
    let toUid: String
    let toName: String
    let status: ContactRequestStatus
    let phone: String?
    let email: String?
}

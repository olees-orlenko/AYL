//
//  PublicProfile.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import Foundation

struct PublicProfile: Identifiable {
    var id: String
    let name: String
    let role: ParticipantRole
    let photoUrl: String?
    let quizBestScore: Int
    let quizBestTotal: Int
}

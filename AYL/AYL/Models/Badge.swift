//
//  Badge.swift
//  AYL
//
//  Created by Олеся Орленко on 08.09.2026.
//

import SwiftUI
 
struct Badge: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let isUnlocked: Bool
}
 
enum BadgeCatalog {
    static func badges(participationsCount: Int, quizBestScore: Int, quizBestTotal: Int, isTopThreeInQuiz: Bool) -> [Badge] {
        let quizPlayed = quizBestTotal > 0
        let quizPerfect = quizPlayed && quizBestScore == quizBestTotal
        return [
            Badge(id: "first_event", title: "Первый шаг", subtitle: "Первое участие", systemImage: "flag.checkered", tint: .minty, isUnlocked: participationsCount >= 1),
            Badge(id: "five_events", title: "Активист", subtitle: "5 мероприятий", systemImage: "figure.walk", tint: .lightBlue, isUnlocked: participationsCount >= 5),
            Badge(id: "ten_events", title: "Рекордсмен", subtitle: "10 мероприятий", systemImage: "star.circle.fill", tint: .violet, isUnlocked: participationsCount >= 10),
            Badge(id: "quiz_played", title: "Знаток", subtitle: "Прошёл квиз", systemImage: "questionmark.circle.fill", tint: .minty, isUnlocked: quizPlayed),
            Badge(id: "quiz_perfect", title: "Отличник", subtitle: "Все ответы верны", systemImage: "checkmark.seal.fill", tint: .lightBlue, isUnlocked: quizPerfect),
            Badge(id: "quiz_top3", title: "Топ-3", subtitle: "Лучшие в рейтинге", systemImage: "medal.fill", tint: .violet, isUnlocked: isTopThreeInQuiz)
        ]
    }
}

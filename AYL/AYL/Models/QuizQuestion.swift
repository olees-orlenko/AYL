//
//  QuizQuestion.swift
//  AYL
//
//  Created by Олеся Орленко on 07.09.2026.
//

import Foundation

struct QuizQuestion: Identifiable {
    var id: String
    let text: String
    let options: [String]
    let correctIndex: Int
}

//
//  NewsComment.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import Foundation

struct NewsComment: Identifiable, Equatable {
    let id: String
    let authorUid: String
    let authorName: String
    let text: String
    let createdAt: Date
}

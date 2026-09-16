//
//  CommentReport.swift
//  AYL
//
//  Created by Олеся Орленко on 16.09.2026.
//

import Foundation

struct CommentReport: Identifiable {
    let id: String
    let newsId: String
    let commentId: String
    let commentText: String
    let commentAuthorUid: String
    let reportedByUid: String
    let createdAt: Date
}

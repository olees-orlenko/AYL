//
//  TermsOfServiceView.swift
//  AYL
//
//  Created by Олеся Орленко on 17.09.2026.
//

import SwiftUI

struct TermsOfServiceView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Условия использования АЮЛ")
                        .font(.title2.bold())
                    Text("Регистрируясь в приложении, вы соглашаетесь со следующими правилами.")
                        .foregroundColor(.secondary)
                    sectionText(
                        title: "1. Комментарии и общение",
                        body: "Приложение позволяет оставлять комментарии к новостям и обмениваться контактами с другими участниками. Мы не терпим оскорбительный, агрессивный, дискриминационный или иной неприемлемый контент и поведение по отношению к другим пользователям."
                    )
                    sectionText(
                        title: "2. Модерация",
                        body: "Каждый пользователь может пожаловаться на комментарий, нарушающий правила, а также заблокировать другого пользователя, скрыв его комментарии. Администрация рассматривает жалобы и удаляет нарушающий контент, а при необходимости блокирует нарушителя — как правило, в течение 24 часов с момента поступления жалобы."
                    )
                    sectionText(
                        title: "3. Ваши данные",
                        body: "Вы можете в любой момент удалить свой аккаунт и все связанные с ним данные в разделе «Кабинет» → «Удалить аккаунт». Подробнее — в Политике конфиденциальности."
                    )
                    sectionText(
                        title: "4. Ответственность",
                        body: "Нарушение этих условий может привести к удалению вашего контента и блокировке аккаунта без предупреждения."
                    )
                }
                .padding()
            }
            .navigationTitle("Условия использования")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
    
    private func sectionText(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body).font(.subheadline).foregroundColor(.secondary)
        }
    }
}

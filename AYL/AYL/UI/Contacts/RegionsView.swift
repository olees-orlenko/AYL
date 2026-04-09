//
//  ContactsView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.04.2026.
//

import SwiftUI

// MARK: - ContactsView

struct RegionsView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    
    private let tgAltai = "https://t.me/aylaltay"
    private let tgKrasnodar = "https://t.me/ayl_krd"
    private let vkKrasnodar = "https://vk.com/ayl_krd"
    private let siteKrasnodar = "https://aylkrd.tilda.ws/"
    private let tgBarnaul = "https://t.me/"
    private let vkBarnaul = "https://vk.com/club241886"
    private let tgOrel = "https://t.me/AYLOrel"
    private let tgTomsk = "https://t.me/tomskaul"
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    headerSection
                    introSection
                    regionsList
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("АЮЛ в регионах")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var introSection: some View {
        Text("Наша ассоциация проводит мероприятия по всей России. Узнать о событиях в регионах вы можете в их социальных сетях!")
            .font(.body)
            .lineSpacing(5)
    }
    
    private var regionsList: some View {
        VStack(alignment: .leading, spacing: 25) {
            regionRow(name: "Республика Алтай", telegram: tgAltai)
            regionRow(name: "Краснодарский край",
                      telegram: tgKrasnodar,
                      website: siteKrasnodar,
                      vkontakte: vkKrasnodar)
            regionRow(name: "Барнаул", vkontakte: vkBarnaul)
            regionRow(name: "Орёл", telegram: tgOrel)
            regionRow(name: "Томск", telegram: tgTomsk)
        }
    }
    
    // MARK: - Toolbar
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func regionRow(name: String, telegram: String? = nil, website: String? = nil, vkontakte: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image("ayl1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(name)
                    .font(.system(size: 20, weight: .bold))
            }
            VStack(alignment: .leading, spacing: 6) {
                if let tg = telegram {
                    linkItem(title: "Телеграм-канал", url: tg)
                }
                if let site = website {
                    linkItem(title: "Сайт", url: site)
                }
                if let vk = vkontakte {
                    linkItem(title: "Вконтакте", url: vk)
                }
            }
            .padding(.leading, 36)
        }
    }
    
    private func linkItem(title: String, url: String) -> some View {
        Group {
            if let targetUrl = URL(string: url) {
                Link(destination: targetUrl) {
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundColor(.violet)
                }
            } else {
                Text(title)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
    }
}

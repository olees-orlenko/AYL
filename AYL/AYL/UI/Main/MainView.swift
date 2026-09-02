//
//  MainView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.04.2026.
//

import SwiftUI

// MARK: - MainView

struct MainView: View {
    
    // MARK: - Properties
    
    private let documentsUrlString = "https://ayl.ru/dokumenty"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var tapCount = 0
    @State private var showingLogin = false
    @State private var showingProfile = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    mainContent
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.lightBlue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? .minty : .lightBlue)
                    }
                }
            }
            .sheet(isPresented: $showingLogin) {
                LoginView()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            logoSection
            headerSection
            introSection
            formatsSection
            methodologySection
            whyChooseUsLink
            footerSection
        }
    }
    
    private var logoSection: some View {
        HStack {
            Spacer()
            Image("ayl1")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Spacer()
        }
        .onTapGesture {
            tapCount += 1
            if tapCount == 5 {
                showingLogin = true
                tapCount = 0
            }
        }
        
        .padding(.top, 10)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О нас")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("**Мы молодёжная некоммерческая организация**")
                .font(.system(size: 18))
            Text("Проводим лидерские тренинги для молодёжи более 30 лет. Обучение проходит по авторским программам АЮЛ®")
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    private var formatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("**Проводим тренинги в разных форматах:**")
                .padding(.top, 10)
            VStack(alignment: .leading, spacing: 10) {
                bulletPoint(text: "Конференции — пятидневные тренинги")
                bulletPoint(text: "Однодневные тренинги")
            }
        }
    }
    
    private var methodologySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("**Обучение проходит в формате:**")
                .padding(.top, 10)
            VStack(alignment: .leading, spacing: 10) {
                bulletPoint(text: "малых групп по 6-12 человек, у каждой из которых есть свой ведущий (человек, который дает материал и проводит малые группы у участников на протяжении всего события со своей группой)")
                
                bulletPoint(text: "общих сессий – общие лекции-тренинги для всех участников мероприятия")
            }
        }
    }
    
    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ознакомиться с краткой информацией об организации и учредительными документами вы можете по **кнопке ниже**")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            documentsButton
        }
    }
    
    private var documentsButton: some View {
        NavigationLink {
            DocumentWebView(urlString: documentsUrlString)
        } label: {
            Text("Документы")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.minty)
                .cornerRadius(15)
        }
    }
    
    private var whyChooseUsLink: some View {
        NavigationLink {
            WhyChooseUsView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Почему выбирают нас?")
                        .font(.title3.bold())
                        .foregroundColor(.violet)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.violet)
            }
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Helpers
    
    func bulletPoint(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.lightBlue)
            Text(text)
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

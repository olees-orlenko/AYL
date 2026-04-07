//
//  WhyChooseUsView.swift
//  AYL
//
//  Created by Олеся Орленко on 06.04.2026.
//

import SwiftUI

import SwiftUI

// MARK: - WhyChooseUsView

struct WhyChooseUsView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            introTextSection
            feature1Section
            feature2Section
            feature3Section
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Почему выбирают нас?")
                .font(.title2.bold())
            Rectangle()
                .frame(width: 60, height: 4)
                .foregroundColor(.violet)
        }
    }
    
    private var introTextSection: some View {
        Text("Мы разработали собственные подходы и методику, которая помогает участникам проходить обучение в комфортной атмосфере и развивать свои способности.")
            .font(.body)
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
    }
    
    private var feature1Section: some View {
        featureSection(number: "-1-", title: "Молодые учат молодых", description: "Это одна из главных ценностей АЮЛ. Данный принцип позволяет организаторам и участникам говорить на одном языке, что способствует лучшему усвоению новых навыков и знаний.")
    }
    
    private var feature2Section: some View {
        featureSection(number: "-2-", title: "Полное погружение в процесс", description: "В отличие от других организаций, мы проводим конференции (5-дневные тренинги) на территории базы, на которой участники не только проходят обучение, но и живут в течение всего времени. Это позволяет погрузиться в рабочий процесс и, благодаря практическим частям нашей программы, попрактиковаться в изученном материале в режиме \"реального времени\".")
    }
    
    private var feature3Section: some View {
        featureSection(number: "-3-", title: "Уникальная атмосфера", description: "Важной ценностью АЮЛ является атмосфера сотрудничества и безопасности. На наших мероприятиях каждый участник может свободно выражать свои мысли, зная, что он будет услышан. Такая тёплая атмосфера остаётся надолго в сердце каждого, кто хоть раз побывал на нашем тренинге.")
    }
    
    // MARK: - Toolbar Content
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func featureSection(number: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(number)
                .font(.caption)
                .foregroundColor(.lightBlue)
                .padding(.bottom, 0)
            Text(title)
                .font(.headline)
                .padding(.bottom, 2)
            Text(description)
                .font(.body)
                .lineSpacing(4)
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Preview

struct WhyChooseUsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WhyChooseUsView()
        }
    }
}


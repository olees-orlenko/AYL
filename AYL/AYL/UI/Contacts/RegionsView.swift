//
//  ContactsView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.04.2026.
//

import SwiftUI

// MARK: - RegionsView

struct RegionsView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = RegionsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAddSheet = false
    @State private var selectedRegion: RegionContact? = nil
    
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
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .sheet(item: $selectedRegion) { region in
            RegionEditView(viewModel: viewModel, region: region)
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingAddSheet) {
            RegionEditView(viewModel: viewModel, region: nil)
                .environmentObject(authManager)
        }
        .onAppear {
            viewModel.fetchData()
        }
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
    
    @ViewBuilder
    private var regionsList: some View {
        if !viewModel.isLoading && viewModel.regions.isEmpty {
            Text("Список пуст")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        } else {
            VStack(alignment: .leading, spacing: 25) {
                ForEach(viewModel.regions) { region in
                    regionRow(region)
                        .contextMenu {
                            if authManager.isAdminLoggedIn {
                                Button {
                                    selectedRegion = region
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteRegion(id: region.id)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
        }
        if authManager.isAdminLoggedIn {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func regionRow(_ region: RegionContact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image("ayl1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(region.name)
                    .font(.system(size: 20, weight: .bold))
            }
            VStack(alignment: .leading, spacing: 6) {
                if let tg = region.telegramLink, !tg.isEmpty {
                    linkItem(title: "Телеграм-канал", url: tg)
                }
                if let site = region.websiteLink, !site.isEmpty {
                    linkItem(title: "Сайт", url: site)
                }
                if let vk = region.vkLink, !vk.isEmpty {
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

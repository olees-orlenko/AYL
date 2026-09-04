//
//  ContactsView.swift
//  AYL
//
//  Created by Олеся Орленко on 08.04.2026.
//

import SwiftUI

struct ContactsView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ContactsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEdit = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            logoSection
                            headerSection
                            detailedInfoSection
                            socialsSection
                            regionsNavigationLink
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Color.clear.frame(height: 0)
                }
                if authManager.isAdminLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingEdit = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Выйти") { authManager.signOut() }
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                ContactsEditView(viewModel: viewModel)
                    .environmentObject(authManager)
            }
            .onAppear {
                viewModel.fetchData()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var logoSection: some View {
        HStack {
            Spacer()
            Image("ayl1")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Контакты")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var detailedInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            contactLinkItem(title: "Сайт:", value: viewModel.info.websiteDisplay, url: viewModel.info.website)
            emailButtonItem(title: "Электронная почта:", value: viewModel.info.email, url: viewModel.info.emailURL)
            phoneButtonItem(title: "Телефон:", value: viewModel.info.phone, url: viewModel.info.phoneURL)
            Text("\(viewModel.info.directorTitle)\n\(viewModel.info.directorName)")
                .font(.body)
        }
    }
    
    private var socialsSection: some View {
        HStack(spacing: 25) {
            socialCircleButton(systemIcon: "paperplane.fill", url: viewModel.info.telegram)
            socialCircleButton(systemIcon: "play.fill", url: viewModel.info.youtube)
            socialCircleButton(imageName: "vk_logo", url: viewModel.info.vk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var regionsNavigationLink: some View {
        NavigationLink {
            RegionsView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("АЮЛ в регионах")
                        .font(.title3.bold())
                        .foregroundColor(.violet)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.violet)
            }
            .padding(.vertical, 15)
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func socialCircleButton(systemIcon: String? = nil, imageName: String? = nil, url: String) -> some View {
        if let validURL = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) {
            Link(destination: validURL) {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.lightBlue)
                    if let systemIcon = systemIcon {
                        Image(systemName: systemIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    } else if let imageName = imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.top, 20)
            }
        } else {
            VStack(spacing: 4) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
                Text("Ошибка")
                    .font(.system(size: 8))
                    .foregroundColor(.red)
            }
            .frame(width: 40, height: 40)
            .padding(.top, 20)
        }
    }
    
    private func contactLinkItem(title: String, value: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let validURL = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) {
                Link(value, destination: validURL)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lightBlue)
            } else {
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                    .help("Некорректная ссылка")
            }
        }
    }
    
    private func emailButtonItem(title: String, value: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button {
                if let mailURL = URL(string: url) {
                    if UIApplication.shared.canOpenURL(mailURL) {
                        UIApplication.shared.open(mailURL)
                    }
                }
            } label: {
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lightBlue)
            }
        }
    }
    
    private func phoneButtonItem(title: String, value: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button {
                if let phoneURL = URL(string: url) {
                    if UIApplication.shared.canOpenURL(phoneURL) {
                        UIApplication.shared.open(phoneURL)
                    }
                }
            } label: {
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lightBlue)
            }
        }
    }
}

// MARK: - Preview

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}

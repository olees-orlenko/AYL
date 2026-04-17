//
//  StaffView.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import SwiftUI
import FirebaseAuth

struct StaffView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel = StaffViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditSheet = false
    @State private var selectedMember: StaffMember? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if !viewModel.staffMembers.isEmpty {
                            ForEach(viewModel.staffMembers) { member in
                                StaffCard(member: member)
                                    .onTapGesture {
                                        if authManager.isAdminLoggedIn {
                                            selectedMember = member
                                            showingEditSheet = true
                                        }
                                    }
                            }
                        } else {
                            VStack {
                                Spacer()
                                emptySectionHeader
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                if authManager.isAdminLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            selectedMember = nil
                            showingEditSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Выйти") {
                            authManager.signOut()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                StaffEditView(viewModel: viewModel, member: selectedMember)
                    .environmentObject(authManager)
                    .id(selectedMember?.id ?? "new")
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchData()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Штат АЮЛ")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var emptySectionHeader: some View {
        Text("Список пуст")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray)
    }
}

// MARK: - Preview

struct StaffView_Previews: PreviewProvider {
    static var previews: some View {
        StaffView()
    }
}

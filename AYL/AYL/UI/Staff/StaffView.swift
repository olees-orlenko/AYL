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
    @State private var showingAddSheet = false
    @State private var selectedMember: StaffMember? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        if !viewModel.isLoading {
                            if !viewModel.staffMembers.isEmpty {
                                ForEach(viewModel.staffMembers) { member in
                                    StaffCard(member: member)
                                        .contextMenu {
                                            if authManager.isAdminLoggedIn {
                                                Button {
                                                    selectedMember = member
                                                    showingEditSheet = true
                                                } label: {
                                                    Label("Редактировать", systemImage: "pencil")
                                                }
                                                Button(role: .destructive) {
                                                    viewModel.deleteMember(id: member.id)
                                                } label: {
                                                    Label("Удалить", systemImage: "trash")
                                                }
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
            .toolbar {
                if authManager.isAdminLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            selectedMember = nil
                            showingAddSheet = true
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
            .sheet(item: $selectedMember) { member in
                StaffEditView(viewModel: viewModel, member: member)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingAddSheet) {
                StaffEditView(viewModel: viewModel, member: nil)
                    .environmentObject(authManager)
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

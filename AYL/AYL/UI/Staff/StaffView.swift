//
//  StaffView.swift
//  AYL
//
//  Created by Олеся Орленко on 14.04.2026.
//

import SwiftUI

struct StaffView: View {
    
    // MARK: - Properties

    @StateObject var viewModel = StaffViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if !viewModel.isLoading && !viewModel.staffMembers.isEmpty {
                        VStack(alignment: .leading, spacing: 20) {
                            headerSection
                            ForEach(viewModel.staffMembers) { member in
                                StaffCard(member: member)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    } else if !viewModel.isLoading && viewModel.staffMembers.isEmpty {
                        VStack {
                            Spacer()
                            Text("Список пуст")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
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
}

// MARK: - Preview

struct StaffView_Previews: PreviewProvider {
    static var previews: some View {
        StaffView()
    }
}

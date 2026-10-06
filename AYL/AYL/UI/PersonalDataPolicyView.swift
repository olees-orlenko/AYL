//
//  PersonalDataPolicyView.swift
//  AYL
//
//  Created by Олеся Орленко on 06.10.2026.
//

import SwiftUI

struct PersonalDataPolicyView: View {
    var body: some View {
        NavigationStack {
            DocumentWebView(urlString: "https://olees-orlenko.github.io/ayl-app-site/pdn.html")
                .navigationTitle("Обработка персональных данных")
        }
    }
}

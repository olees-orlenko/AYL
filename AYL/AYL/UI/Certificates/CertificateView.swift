//
//  CertificateView.swift
//  AYL
//
//  Created by Олеся Орленко on 09.09.2026.
//

import SwiftUI

struct CertificateView: View {
    
    let participantName: String
    let eventTitle: String
    let eventDate: Date
    
    @Environment(\.dismiss) var dismiss
    @State private var image: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                if let image {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Сертификат", image: Image(uiImage: image))) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onAppear { generate() }
        }
    }
    
    private func generate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        image = CertificateGenerator.makeImage(
            participantName: participantName,
            eventTitle: eventTitle,
            eventDateText: formatter.string(from: eventDate)
        )
    }
}

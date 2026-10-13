//
//  EventFormView.swift
//  AYL
//
//  Created by Олеся Орленко on 13.10.2026.
//

import SwiftUI
import PhotosUI

struct EventFormView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: EventsViewModel
    let existingEvent: Event?
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var type: EventType = .conference
    @State private var title = ""
    @State private var city = ""
    @State private var eventDate = Date()
    @State private var directorName = ""
    @State private var executiveDirectorName = ""
    @State private var adminTeamNames = ""
    @State private var gammaNames = ""
    @State private var facilitatorNames = ""
    @State private var delegateNames = ""
    
    @State private var selectedCoverItem: PhotosPickerItem?
    @State private var coverImageData: Data?
    @State private var existingImageUrl: String?
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var newPhotosData: [Data] = []
    @State private var existingPhotoUrls: [String] = []
    
    @State private var isUploading = false
    
    private var isFormValid: Bool {
        !city.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isEditing: Bool { existingEvent != nil }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Тип и дата") {
                    Picker("Тип мероприятия", selection: $type) {
                        ForEach(EventType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    DatePicker("Дата", selection: $eventDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                    TextField("Город", text: $city)
                }
                Section("Название") {
                    TextField("Необязательно", text: $title)
                }
                Section("Обложка") {
                    coverPicker
                }
                Section("Участники") {
                    TextField("Директор", text: $directorName)
                    TextField("Исполнительный директор", text: $executiveDirectorName)
                    TextField("Административная команда", text: $adminTeamNames)
                    TextField("Гамма", text: $gammaNames)
                    TextField("Ведущие", text: $facilitatorNames)
                    TextField("Делегаты", text: $delegateNames)
                }
                Section("Фотографии") {
                    photosPicker
                }
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Button {
                    save()
                } label: {
                    if isUploading || viewModel.isSaving {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text(isEditing ? "Сохранить" : "Добавить")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || isUploading || viewModel.isSaving)
            }
            .navigationTitle(isEditing ? "Редактировать мероприятие" : "Новое мероприятие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear(perform: prefillIfNeeded)
            .onChange(of: selectedCoverItem) { _, newItem in loadCover(newItem) }
            .onChange(of: selectedPhotoItems) { _, newItems in loadPhotos(newItems) }
        }
    }
    
    // MARK: - Subviews
    
    private var coverPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(10)
            } else if let existingImageUrl, let url = URL(string: existingImageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { ProgressView() }
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(10)
            }
            PhotosPicker("Выбрать обложку", selection: $selectedCoverItem, matching: .images)
        }
    }
    
    private var photosPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !existingPhotoUrls.isEmpty || !newPhotosData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(existingPhotoUrls, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: { ProgressView() }
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(alignment: .topTrailing) {
                                        removeButton { existingPhotoUrls.removeAll { $0 == urlString } }
                                    }
                            }
                        }
                        ForEach(newPhotosData.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: newPhotosData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(alignment: .topTrailing) {
                                        removeButton { newPhotosData.remove(at: index) }
                                    }
                            }
                        }
                    }
                }
            }
            PhotosPicker("Добавить фотографии", selection: $selectedPhotoItems, matching: .images)
        }
    }
    
    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
        .padding(2)
    }
    
    // MARK: - Private methods
    
    private func prefillIfNeeded() {
        guard let event = existingEvent else { return }
        type = event.type
        title = event.title
        city = event.city
        eventDate = event.eventDate
        directorName = event.directorName
        executiveDirectorName = event.executiveDirectorName
        adminTeamNames = event.adminTeamNames
        gammaNames = event.gammaNames
        facilitatorNames = event.facilitatorNames
        delegateNames = event.delegateNames
        existingImageUrl = event.imageUrl
        existingPhotoUrls = event.photoUrls
    }
    
    private func loadCover(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let resized = resizedJPEGData(from: data, maxDimension: 1600, quality: 0.75) {
                coverImageData = resized
            }
        }
    }
    
    private func loadPhotos(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let resized = resizedJPEGData(from: data, maxDimension: 1600, quality: 0.7) {
                    newPhotosData.append(resized)
                }
            }
            selectedPhotoItems = []
        }
    }
    
    private func resizedJPEGData(from data: Data, maxDimension: CGFloat, quality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
    
    private func save() {
        guard let uid = authManager.currentUserId else { return }
        isUploading = true
        let eventId = existingEvent?.id ?? UUID().uuidString
        
        func finishSaving(coverUrl: String?) {
            var uploadedUrls: [String] = []
            let group = DispatchGroup()
            for data in newPhotosData {
                group.enter()
                viewModel.uploadEventPhoto(eventId: eventId, imageData: data) { url in
                    if let url { uploadedUrls.append(url) }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                viewModel.saveEvent(
                    id: eventId,
                    isNew: existingEvent == nil,
                    type: type,
                    title: title,
                    city: city,
                    eventDate: eventDate,
                    imageUrl: coverUrl ?? existingImageUrl,
                    directorName: directorName,
                    executiveDirectorName: executiveDirectorName,
                    adminTeamNames: adminTeamNames,
                    gammaNames: gammaNames,
                    facilitatorNames: facilitatorNames,
                    delegateNames: delegateNames,
                    photoUrls: existingPhotoUrls + uploadedUrls,
                    authorUid: existingEvent?.authorUid ?? uid
                ) { success in
                    isUploading = false
                    if success { dismiss() }
                }
            }
        }
        
        if let coverImageData {
            viewModel.uploadCoverImage(eventId: eventId, imageData: coverImageData) { url in
                finishSaving(coverUrl: url)
            }
        } else {
            finishSaving(coverUrl: nil)
        }
    }
}

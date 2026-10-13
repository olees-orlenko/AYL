//
//  EventsListView.swift
//  AYL
//
//  Created by Олеся Орленко on 13.10.2026.
//

import SwiftUI

struct EventsListView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = EventsViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var cityFilter = ""
    @State private var showingDateFilter = false
    @State private var dateFrom: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var dateTo: Date = Date()
    @State private var showingAddSheet = false
    
    private var filteredEvents: [Event] {
        viewModel.events.filter { event in
            let trimmedCity = cityFilter.trimmingCharacters(in: .whitespaces)
            let matchesCity = trimmedCity.isEmpty || event.city.localizedCaseInsensitiveContains(trimmedCity)
            guard matchesCity else { return false }
            guard showingDateFilter else { return true }
            let from = Calendar.current.startOfDay(for: dateFrom)
            let to = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: dateTo)) ?? dateTo
            return event.eventDate >= from && event.eventDate <= to
        }
    }
    
    private var conferences: [Event] { filteredEvents.filter { $0.type == .conference } }
    private var trainings: [Event] { filteredEvents.filter { $0.type == .training } }
    
    private var canAddEvent: Bool {
        authManager.isParticipantLoggedIn || authManager.isAdminLoggedIn
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    filtersSection
                    if viewModel.isLoading && viewModel.events.isEmpty {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                    } else if filteredEvents.isEmpty {
                        emptyState
                    } else {
                        eventsSections
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .refreshable { viewModel.fetchEvents() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canAddEvent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showingAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EventFormView()
            }
            .onAppear { viewModel.fetchEvents() }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Прошедшие мероприятия")
                .font(.title.bold())
            Rectangle()
                .frame(width: 50, height: 4)
                .foregroundColor(.violet)
        }
        .padding(.top, 10)
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Поиск по городу", text: $cityFilter)
                .textFieldStyle(.roundedBorder)
            Toggle("Фильтр по датам", isOn: $showingDateFilter.animation())
                .tint(.minty)
            if showingDateFilter {
                DatePicker("С", selection: $dateFrom, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                DatePicker("По", selection: $dateTo, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
            }
        }
    }
    
    private var emptyState: some View {
        Text("Мероприятий по заданным условиям не найдено")
            .foregroundColor(.gray)
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }
    
    private var eventsSections: some View {
        VStack(alignment: .leading, spacing: 24) {
            eventsGroup(title: "Конференции", items: conferences)
            eventsGroup(title: "Тренинги", items: trainings)
        }
    }
    
    @ViewBuilder
    private func eventsGroup(title: String, items: [Event]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.violet)
                VStack(spacing: 10) {
                    ForEach(items) { event in
                        NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                            eventRow(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func eventRow(_ event: Event) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.displayTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                    Text(event.city)
                    Text("·")
                    Text(event.formattedDate)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.violet)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}

// MARK: - Preview

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}

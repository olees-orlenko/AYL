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
    @State private var showingFilters = false
    
    private var hasActiveFilters: Bool {
        !cityFilter.trimmingCharacters(in: .whitespaces).isEmpty || showingDateFilter
    }
    
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
                    if canAddEvent {
                        if viewModel.isLoading && viewModel.events.isEmpty {
                            ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                        } else if filteredEvents.isEmpty {
                            emptyState
                        } else {
                            eventsSections
                        }
                    } else {
                        Text("Войдите в личный кабинет участника (иконка профиля на главном экране), чтобы увидеть прошедшие мероприятия")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .refreshable { if canAddEvent { viewModel.fetchEvents() } }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canAddEvent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button { showingFilters = true } label: {
                                Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(hasActiveFilters ? .minty : .lightBlue)
                            }
                            Button { showingAddSheet = true } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EventFormView(viewModel: viewModel, existingEvent: nil)
            }
            .sheet(isPresented: $showingFilters) {
                filtersSheet
            }
            .onAppear {
                if canAddEvent { viewModel.fetchEvents() }
            }
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
    
    private var filtersSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Фильтры")
                .font(.headline)
                .padding(.top, 24)
            filtersSection
            Spacer()
            Button("Готово") {
                showingFilters = false
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.minty)
            .cornerRadius(15)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Поиск по городу", text: $cityFilter)
                    .textFieldStyle(.roundedBorder)
                if !cityFilter.isEmpty {
                    Button {
                        cityFilter = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            Toggle("Фильтр по датам", isOn: $showingDateFilter)
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
                VStack(spacing: 16) {
                    ForEach(items) { event in
                        NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                            EventCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}

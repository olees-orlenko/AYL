//
//  CalendarManager.swift
//  AYL
//
//  Created by Олеся Орленко on 04.09.2026.
//

import Foundation
import EventKit

final class CalendarManager {

    static let shared = CalendarManager()

    private let eventStore = EKEventStore()
    private let identifiersDefaultsKey = "calendarEventIdentifiers"

    private init() {}

    func addEvent(newsId: String, title: String, startDate: Date, notes: String? = nil, completion: @escaping (Bool) -> Void = { _ in }) {
        requestAccessIfNeeded { [weak self] granted in
            guard let self, granted else {
                completion(false)
                return
            }
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(60 * 60)
            event.notes = notes
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            do {
                try self.eventStore.save(event, span: .thisEvent)
                self.saveIdentifier(event.eventIdentifier, for: newsId)
                completion(true)
            } catch {
                print("Calendar: не удалось добавить \"\(title)\" в календарь — \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    func removeEvent(newsId: String) {
        guard let identifier = identifier(for: newsId),
              let event = eventStore.event(withIdentifier: identifier) else {
            removeIdentifier(for: newsId)
            return
        }
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            print("Calendar: не удалось удалить событие мероприятия \(newsId) — \(error.localizedDescription)")
        }
        removeIdentifier(for: newsId)
    }

    // MARK: - Access

    private func requestAccessIfNeeded(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if let error {
                    print("Calendar: ошибка запроса доступа — \(error.localizedDescription)")
                }
                DispatchQueue.main.async { completion(granted) }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                if let error {
                    print("Calendar: ошибка запроса доступа — \(error.localizedDescription)")
                }
                DispatchQueue.main.async { completion(granted) }
            }
        }
    }

    // MARK: - EventIdentifier

    private func identifier(for newsId: String) -> String? {
        (UserDefaults.standard.dictionary(forKey: identifiersDefaultsKey) as? [String: String])?[newsId]
    }

    private func saveIdentifier(_ identifier: String, for newsId: String) {
        var dict = (UserDefaults.standard.dictionary(forKey: identifiersDefaultsKey) as? [String: String]) ?? [:]
        dict[newsId] = identifier
        UserDefaults.standard.set(dict, forKey: identifiersDefaultsKey)
    }

    private func removeIdentifier(for newsId: String) {
        var dict = (UserDefaults.standard.dictionary(forKey: identifiersDefaultsKey) as? [String: String]) ?? [:]
        dict.removeValue(forKey: newsId)
        UserDefaults.standard.set(dict, forKey: identifiersDefaultsKey)
    }
}

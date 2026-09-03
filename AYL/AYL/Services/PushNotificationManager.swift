//
//  PushNotificationManager.swift
//  AYL
//
//  Created by Олеся Орленко on 18.08.2026.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseFirestore

let pushTopicAllUsers = "news_all"

let pushEnabledDefaultsKey = "pushNotificationsEnabled"

final class PushNotificationManager: NSObject {

    static let shared = PushNotificationManager()

    private let db = Firestore.firestore()

    var isPushEnabled: Bool {
        UserDefaults.standard.object(forKey: pushEnabledDefaultsKey) as? Bool ?? true
    }

    private override init() {
        super.init()
    }

    func setPushEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: pushEnabledDefaultsKey)
        guard Messaging.messaging().apnsToken != nil else {
            print("Push: APNs токен ещё не готов — переключатель сохранён, применится, когда токен придёт")
            return
        }
        if enabled {
            Messaging.messaging().subscribe(toTopic: pushTopicAllUsers) { error in
                if let error {
                    print("Push: не удалось подписаться на топик \(pushTopicAllUsers) — \(error.localizedDescription)")
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: pushTopicAllUsers) { error in
                if let error {
                    print("Push: не удалось отписаться от топика \(pushTopicAllUsers) — \(error.localizedDescription)")
                }
            }
        }
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func requestAuthorizationAndRegister() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Push: ошибка запроса разрешения — \(error.localizedDescription)")
            }
            guard granted else {
                print("Push: пользователь не разрешил уведомления")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    private func saveTokenToFirestore(_ token: String, userId: String? = nil) {
        var data: [String: Any] = [
            "token": token,
            "platform": "ios",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let userId {
            data["userId"] = userId
        }
        db.collection("deviceTokens").document(token).setData(data, merge: true) { error in
            if let error {
                print("Push: не удалось сохранить токен в Firestore — \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - MessagingDelegate

extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        saveTokenToFirestore(fcmToken)
        if isPushEnabled {
            Messaging.messaging().subscribe(toTopic: pushTopicAllUsers) { error in
                if let error {
                    print("Push: не удалось подписаться на топик \(pushTopicAllUsers) — \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let newsId = userInfo["newsId"] as? String {
            DispatchQueue.main.async {
                NavigationCoordinator.shared.openNews(id: newsId)
            }
        }
        completionHandler()
    }
}

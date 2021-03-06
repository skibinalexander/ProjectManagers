//
//  PushNotificationsManager.swift
//  Vezu
//
//  Created by Пользователь on 15/02/2019.
//  Copyright © 2019 VezuAppDevTeam. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase

public let PNMRegistrationAllNotifictionName: Notification.Name = Notification.Name(rawValue: "PNMRegistrationAllNotifactionName")
public let PNMRegistrationFCMNotifictionName: Notification.Name = Notification.Name(rawValue: "PNMRegistrationFCMNotifactionName")

private let gcmMessageIDKey = "gcm.message_id"

class PushNotificationsManager: NSObject {
    
    static var tokenAPNS:   String?
    static var tokenFCM:    String?
    
    static let manager: PushNotificationsManager = PushNotificationsManager()
    
    func registerForPushNotifications(delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard self != nil else { return }
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            UNUserNotificationCenter.current().delegate = delegate
            Messaging.messaging().delegate = self
            
            self?.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}

//  MARK: UNUserNotificationCenterDelegate

extension PushNotificationsManager {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        guard let fcm = Messaging.messaging().fcmToken else {
            print("PushNotificationsManager: Messaging.messaging().fcmToken is nil!")
            return
        }
        
        let apns = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        print("APNS = \(apns)")
        print("FCM = \(fcm)")
        
        PushNotificationsManager.tokenAPNS  = apns
        PushNotificationsManager.tokenFCM   = fcm
        
        NotificationCenter.default.post(name: PNMRegistrationAllNotifictionName, object: nil, userInfo: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
}

//  MARK: PushNotificationsManager + FirebaseMessaging

extension PushNotificationsManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        PushNotificationsManager.tokenFCM = fcmToken
        NotificationCenter.default.post(name: PNMRegistrationFCMNotifictionName, object: nil, userInfo: nil)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

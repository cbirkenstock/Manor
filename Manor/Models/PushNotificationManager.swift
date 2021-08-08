//
//  PushNotificationManager.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/21/21.
//

import Firebase
import FirebaseMessaging
import FirebaseFirestore
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    

    
    /*let UserEmail: String
    init(userEmail: String) {
        self.UserEmail = userEmail
        super.init()
    }*/
    
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self


          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
    
    /*func updateFirestorePushTokenIfNeeded() {
        Messaging.messaging().token { [self] token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            let userRef = Firestore.firestore().collection("users").document(UserEmail)
            userRef.setData(["fcmToken": token], merge: true)
          }
        }
    }*/
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
    

    
}


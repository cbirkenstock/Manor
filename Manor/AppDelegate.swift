//
//  AppDelegate.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/10/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,  MessagingDelegate {
    
    let defaults = UserDefaults.standard
    let imageCache = NSCache<NSString, AnyObject>()
    let firebaseManager = FirebaseManagerViewController()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.defaults.setValue(nil, forKey: "savedPassword")
        
        FirebaseApp.configure()
        
        //let user: User! = Firebase.Auth.auth().currentUser
        
        let pushNotificationManager = PushNotificationManager()
        
        pushNotificationManager.registerForPushNotifications()
        
        configureAmplify()
        /*firebaseManager.downloadContactPhotos { contactPhotosDictionary in
            print("photos1")
            print(contactPhotosDictionary)
        }*/
        

        return true
    }
    

    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            
        } catch {
            print("error configuring Amplify", error)
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    /*func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
     UIApplication.shared.applicationIconBadgeNumber = 40
     }*/
    
    
}


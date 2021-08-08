//
//  PageViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/27/21.
//

import UIKit
import Firebase

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    //creates two story boards
    lazy var myControllers:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "DMContactView")
        let vc2 = sb.instantiateViewController(withIdentifier: "GroupChatContactView")
        return [vc1, vc2]
    }()
    
    let user: User! = Firebase.Auth.auth().currentUser
    let usersRef = Database.database().reference().child("users")
    
    var pushNotificationManager = PushNotificationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commaEmail = self.user.email!.replacingOccurrences(of: ".", with: ",")
        
        usersRef.child(commaEmail).observeSingleEvent(of: DataEventType.value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard value["venmoName"] != nil else {
                    let alert = UIAlertController(title: "Venmo Username", message: "please provide your venmo username. Make sure to capitalize each character appropriately", preferredStyle: .alert)
                    alert.addTextField()
                    alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { UIAlertAction in
                        print(UIAlertAction)
                        let answer = alert.textFields![0].text
                        self.usersRef.child("\(commaEmail)/venmoName").setValue(answer ?? "")
                    }))
                    self.present(alert, animated: true)
                    return
                }
            }
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableSwipe), name: NSNotification.Name("enableSwipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableSwipe), name: NSNotification.Name("disableSwipe"), object: nil)
        
        
        
        self.dataSource = self
        Messaging.messaging().delegate = self
        
        //updates the FCM token if it has changed so user properly receives notifications
        updateFirestorePushTokenIfNeeded()
        
        
        //sets the fire view controller for page views
        if let first = myControllers.first {
            self.setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    @objc func disableSwipe() {
        print("disabled")
        self.dataSource = nil
    }
    
    @objc func enableSwipe() {
        print("enabled")
        self.dataSource = self
        //notification: NSNotification
    }
    
    //gets the view before the one you are currently on (i.e. if on page 10, returns page 9)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = myControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        
        let before = index - 1
        
        return myControllers[before]
    }
    
    //gets the view after the one you are currently on (i.e. if on page 10, returns page 11)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = myControllers.firstIndex(of: viewController), index < myControllers.count - 1 else {
            return nil
        }
        
        let after = index + 1
        
        return myControllers[after]
    }
    
    //if receives notification from firebase, it will trigger the updating of FCM
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    
    //updates FCM 
    func updateFirestorePushTokenIfNeeded() {
        Messaging.messaging().token { [self] token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("Token \(token)")
                usersRef.child("\(self.user!.email!.replacingOccurrences(of: ".", with: ","))/fcmToken").setValue(token)
            }
        }
    }
    
}

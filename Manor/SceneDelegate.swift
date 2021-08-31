//
//  SceneDelegate.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/10/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins
import SwiftKeychainWrapper

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let defaults = UserDefaults.standard


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        self.defaults.setValue(nil, forKey: "savedPassword")
        
        fetchCurrentAuthSession()
        
        if let email = defaults.string(forKey: "savedEmail") {
            let username = email.replacingOccurrences(of: ".", with: ",")
            let password = KeychainWrapper.standard.string(forKey: "savedPassword")
            //signIn(username: username, password: password ?? "")
            
            /*Auth.auth().addStateDidChangeListener { (auth, user) in
                if user == nil {
                    print("no user")
                } else {
                    print("Firebase User Exists")
                    /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialVC = storyboard.instantiateViewController(withIdentifier: "homeScreenNavigation")
                    //self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = initialVC
                    self.window?.makeKeyAndVisible()*/
                }
            }*/
        }
    }

    
    func fetchCurrentAuthSession() {
        Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                if session.isSignedIn {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialVC = storyboard.instantiateViewController(withIdentifier: "homeScreenNavigation")
                        //self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = initialVC
                        self.window?.makeKeyAndVisible()
                    }
                }
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                /*DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.Segues.ContactPageViewSegue, sender: self)
                }*/
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


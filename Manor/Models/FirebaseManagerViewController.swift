//
//  FirebaseManagerViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/29/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins


class FirebaseManagerViewController: UIViewController {
    
    let imageCache = NSCache<NSString, AnyObject>()
    let user: User! = Firebase.Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func downloadContactPhotos(groupCompletion: @escaping([String:Data]) -> (), dmCompletion: @escaping([String:Data]) -> ()) {
        if let userEmail = user?.email {
            var groupPhotoDictionary: [String:Data] = [:]
            var dmPhotoDictionary: [String:Data] = [:]
            let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
            let chatsByUserRef = Database.database().reference().child("ChatsByUser")
            let commaEmail = userEmail.replacingOccurrences(of: ".", with: ",")
            
            let groupChatsRef = groupChatsByUserRef.child(commaEmail).child("Chats")
            let dmChatsRef = chatsByUserRef.child(commaEmail).child("Chats")
            
            let defaults = UserDefaults.standard
            
            groupChatsRef.observe(DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                let valueCount = postDict.values.count
                var currentCount = 0
                for value in postDict.values {
                    currentCount += 1
                    if let profileImageUrl = value.object(forKey: "profileImageUrl") as? String {
                        if let groupContactPicturesDictionary = defaults.dictionary(forKey: "groupContactPictures") {
                            if groupContactPicturesDictionary.keys.contains(profileImageUrl) {
                                print("image already contained")
                            }
                        } else {
                            Amplify.Storage.downloadData(key: profileImageUrl) { result in
                                switch result {
                                case .success(let data):
                                    print("Success downloading image", data)
                                    if let _ = UIImage(data: data) {
                                        //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                        DispatchQueue.main.async {
                                            groupPhotoDictionary[profileImageUrl] = data
                                        }
                                    }
                                    if currentCount == valueCount {
                                        groupCompletion(groupPhotoDictionary)
                                    }
                                case .failure(let error):
                                    print("failure downloading image", error)
                                }
                            }
                        }
                    }
                }
            })
            
            dmChatsRef.observe(DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                let valueCount = postDict.values.count
                var currentCount = 0
                for value in postDict.values {
                    currentCount += 1
                    if let profileImageUrl = value.object(forKey: "profileImageUrl") as? String {
                        if let dmContactPicturesDictionary = defaults.dictionary(forKey: "dmContactPictures") {
                            if dmContactPicturesDictionary.keys.contains(profileImageUrl) {
                                print("image already contained")
                            }
                        } else {
                            Amplify.Storage.downloadData(key: profileImageUrl) { result in
                                switch result {
                                case .success(let data):
                                    print("Success downloading image", data)
                                    if let _ = UIImage(data: data) {
                                        //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                        DispatchQueue.main.async {
                                            dmPhotoDictionary[profileImageUrl] = data
                                        }
                                    }
                                    if currentCount == valueCount {
                                        dmCompletion(dmPhotoDictionary)
                                    }
                                case .failure(let error):
                                    print("failure downloading image", error)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func downloadChatPhotos(documentID: String, completion: @escaping([String:UIImage]) -> ()) {
        var photoDictionary: [String:UIImage] = [:]
        let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
        let MessagesRef = groupChatMessagesRef.child(documentID).child("Messages")
        
        MessagesRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let valueCount = postDict.values.count
            var currentCount = 0
            for value in postDict.values {
                currentCount += 1
                if let imageURL = value.object(forKey: "imageURL") as? String {
                    Amplify.Storage.downloadData(key: imageURL) { result in
                        switch result {
                        case .success(let data):
                            print("Success downloading image", data)
                            if let image = UIImage(data: data) {
                                //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                DispatchQueue.main.async {
                                    photoDictionary[imageURL] = image
                                }
                            }
                            if currentCount == valueCount {
                                completion(photoDictionary)
                            } else {
                                print(currentCount)
                                print(valueCount)
                            }
                        case .failure(let error):
                            print("failure downloading image", error)
                        }
                    }
                }
            }
        })
    }
    
    func returnContactPhotoArray(contactPhotoDictionary: [String: UIImage]) ->  [String: UIImage] {
        return contactPhotoDictionary
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

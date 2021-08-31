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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func downloadContactPhotos(completion: @escaping([String:UIImage]) -> ()) {
        
        var photoDictionary: [String: UIImage] = [:]
        let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
        let user: User! = Firebase.Auth.auth().currentUser
        
        let userEmail = user.email!
        let commaEmail = userEmail.replacingOccurrences(of: ".", with: ",")
        
        let chatsRef = groupChatsByUserRef.child(commaEmail).child("Chats")
        
        chatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for value in postDict.values {
                if let profileImageUrl = value.object(forKey: "profileImageUrl") as? String {
                    Amplify.Storage.downloadData(key: profileImageUrl) { result in
                        switch result {
                        case .success(let data):
                            print("Success downloading image", data)
                            if let image = UIImage(data: data) {
                                //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                DispatchQueue.main.async {
                                    photoDictionary[profileImageUrl] = image
                                }
                            }
                        case .failure(let error):
                            print("failure downloading image", error)
                        }
                    }
                }
            }
            print("test")
            print(photoDictionary)
            completion(photoDictionary)
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

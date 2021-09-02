//
//  PhotoManagerViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/26/21.
//

import UIKit
import PhotosUI
import Amplify
import Firebase

class PhotoManagerViewController: UIViewController {
    
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatByUsersRef = Database.database().reference().child("GroupChatsByUser")
    let chatMessagesRef = Database.database().reference().child("ChatMessages")
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    let usersRef = Database.database().reference().child("users")
    var user: User! = Firebase.Auth.auth().currentUser
    var userFullName: String?
    var groupMembers: [[String]]?
    var documentID: String?
    var groupChatTitle: String?
    var commaDocumentName: String?
    var otherUserFullName: String?
    var otherUserProfileImageUrl: String?
    var userProfileImageUrl: String?
    var commaOtherUserEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setUpCameraPicker(viewController: UIViewController, desiredPicker: String?) {
        if desiredPicker == "old" {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.allowsEditing = true
            viewController.present(imagePickerController, animated: true)
            return
        } else if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 0
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = viewController as? PHPickerViewControllerDelegate
            viewController.present(picker, animated: true)
        } else {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.allowsEditing = true
            viewController.present(imagePickerController, animated: true)
        }
    }
    
    
    @available(iOS 14, *)
    func processPickerResultsPHP(imagePicker: PHPickerViewController, results: [PHPickerResult], isGroupMessage: Bool) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self)
                { [weak self]  image, error in
                    if error != nil {
                        print("Error", error!)
                        return
                    }
                    
                    if let selectedImage = image as? UIImage {
                        let imageName = NSUUID().uuidString
                        //let storage = Storage.storage()
                        //let ref = storage.reference().child("message_images").child(imageName)
                        
                        
                        if let fileData = selectedImage.jpegData(compressionQuality: 0.2) {
                            Amplify.Storage.uploadData(key: imageName, data: fileData) { result in
                                switch result {
                                case .success(let key):
                                    print("Upload Successful", key)
                                    
                                    let timeStamp = Date().timeIntervalSince1970
                                    let stringTimestamp = "\(timeStamp)"
                                    let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
                                    
                                    if isGroupMessage {
                                        
                                    self?.groupChatMessagesRef.child("\(self!.documentID!)/lastMessage").setValue("\(self!.userFullName!) sent an image")
                                    
                                    self?.groupChatMessagesRef.child(self!.documentID!).child("Messages").child("Message,\(commaTimestamp)").setValue([
                                        "messageSender": self?.userFullName,
                                        "imageURL": key,
                                        "timeStamp": commaTimestamp
                                    ])
                                    
                                    for email in self?.groupMembers?[1] ?? [] {
                                        let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                                        self!.groupChatByUsersRef.child(commaEmail).child("Chats").child(self!.documentID!).setValue([
                                            "title": self!.groupChatTitle,
                                            "documentID": self!.documentID,
                                            "imageURL": key,
                                            "lastMessage": "\(self!.userFullName ?? "") sent an image",
                                            "timeStamp": commaTimestamp
                                        ])
                                    }
                                    } else {
                                        let commaUserEmail = self!.user.email!.replacingOccurrences(of: ".", with: ",")
                                        
                                        self!.chatMessagesRef.child(self!.commaDocumentName!).child("Messages").child(commaTimestamp).setValue([
                                            "messageSender": self!.userFullName!,
                                            "imageURL": imageName,
                                            "timeStamp": timeStamp
                                        ])
                                        
                                        self!.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self!.commaDocumentName!)/senderEmail").setValue(commaUserEmail)
                                        self!.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self!.commaDocumentName!)/lastMessage").setValue("you sent an image")
                                        self!.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self!.commaDocumentName!)/timeStamp").setValue(timeStamp)
                                        self!.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self!.commaDocumentName!)/title").setValue(self!.otherUserFullName)
                                        self!.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self!.commaDocumentName!)/profileImageUrl").setValue(self!.otherUserProfileImageUrl)
                                        
                                        
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/senderEmail").setValue(commaUserEmail)
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/lastMessage").setValue("\(self!.userFullName ?? "") sent an image")
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/timeStamp").setValue(timeStamp)
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/title").setValue(self!.userFullName!)
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/readNotification").setValue(false)
                                        self!.chatsByUserRef.child("\(self!.commaOtherUserEmail!)/Chats/\(self!.commaDocumentName!)/profileImageUrl").setValue(self!.userProfileImageUrl!)
                                    }
                                    
                                case .failure(let error):
                                    print("Upload failed:", error)
                                }
                            }
                            
                            
                            
                            
                            
                            /*Amplify.Storage.getURL(key: imageName) { result in
                             switch result {
                             case .success(let URL):
                             let timeStamp = Date().timeIntervalSince1970
                             let stringTimestamp = "\(timeStamp)"
                             let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
                             
                             let imageURL = URL.absoluteString
                             
                             self?.groupChatMessagesRef.child("\(self!.documentID!)/lastMessage").setValue("\(self!.userFullName!) sent an image")
                             
                             self?.groupChatMessagesRef.child(self!.documentID!).child("Messages").child("Message,\(commaTimestamp)").setValue([
                             "messageSender": self?.userFullName,
                             "imageURL": imageURL,
                             "timeStamp": commaTimestamp
                             ])
                             
                             for email in self?.groupMembers?[1] ?? [] {
                             let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                             self!.groupChatByUsersRef.child(commaEmail).child("Chats").child(self!.documentID!).setValue([
                             "title": self!.groupChatTitle,
                             "documentID": self!.documentID,
                             "imageURL": imageURL,
                             "lastMessage": "\(self!.userFullName ?? "") sent an image",
                             "timeStamp": commaTimestamp
                             ])
                             }
                             
                             case .failure(let error):
                             print(error)
                             }
                             }*/
                            
                        }
                    }
                }
            }
        }
    }
    
    func processPickerResultOld(imagePicker: UIImagePickerController, info: [UIImagePickerController.InfoKey : Any], isTextMessage: Bool?, isGroupMessage: Bool) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            let imageName = NSUUID().uuidString
            //let storage = Storage.storage()
            
            if let fileData = selectedImage.jpegData(compressionQuality: 0.2) {
                Amplify.Storage.uploadData(key: imageName, data: fileData) { result in
                    switch result {
                    case .success(let key):
                        print("Upload Successful", key)
                        
                        let timeStamp = Date().timeIntervalSince1970
                        let stringTimestamp = "\(timeStamp)"
                        let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
                        
                        if isTextMessage ?? true {
                            
                            if isGroupMessage {
                                
                                self.groupChatMessagesRef.child("\(self.documentID ?? "")/lastMessage").setValue("\(self.userFullName ?? "") sent an image")
                                
                                self.groupChatMessagesRef.child(self.documentID!).child("Messages").child("Message,\(commaTimestamp)").setValue([
                                    "messageSender": self.userFullName,
                                    "imageURL": imageName,
                                    "timeStamp": commaTimestamp
                                ])
                                
                                for email in self.groupMembers?[1] ?? [] {
                                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                                    self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID!).setValue([
                                        "title": self.groupChatTitle,
                                        "documentID": self.documentID,
                                        "imageURL": imageName,
                                        "lastMessage": "\(self.userFullName ?? "") sent an image",
                                        "timeStamp": commaTimestamp
                                    ])
                                }
                            } else {
                                
                                let commaUserEmail = self.user.email!.replacingOccurrences(of: ".", with: ",")
                                
                                self.chatMessagesRef.child(self.commaDocumentName!).child("Messages").child(commaTimestamp).setValue([
                                    "messageSender": self.userFullName!,
                                    "imageURL": imageName,
                                    "timeStamp": timeStamp
                                ])
                                
                                self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self.commaDocumentName!)/senderEmail").setValue(commaUserEmail)
                                self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self.commaDocumentName!)/lastMessage").setValue("you sent an image")
                                self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self.commaDocumentName!)/timeStamp").setValue(timeStamp)
                                self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self.commaDocumentName!)/title").setValue(self.otherUserFullName)
                                self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(self.commaDocumentName!)/profileImageUrl").setValue(self.otherUserProfileImageUrl)
                                
                                
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/senderEmail").setValue(commaUserEmail)
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/lastMessage").setValue("\(self.userFullName ?? "") sent an image")
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/timeStamp").setValue(timeStamp)
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/title").setValue(self.userFullName!)
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/readNotification").setValue(false)
                                self.chatsByUserRef.child("\(self.commaOtherUserEmail!)/Chats/\(self.commaDocumentName!)/profileImageUrl").setValue(self.userProfileImageUrl!)
                            }
                        } else {
                            for member in self.groupMembers! {
                                let commaEmail = member[1].replacingOccurrences(of: ".", with: ",")
                                
                                self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/profileImageUrl").setValue(imageName)
                            }
                        }
                    case .failure(let error):
                        print("Upload failed:", error)
                    }
                }
            }
        }
    }
    /*if let uploadData = selectedImage.jpegData(compressionQuality: 0.2) {
     ref.putData(uploadData, metadata: nil) { metaData, err in
     
     if err != nil {
     print("failed to upload image:", err!)
     return
     }
     
     ref.downloadURL { url, err in
     if err != nil {
     print("failed to download URL", err!)
     } else if let imageURl = url?.absoluteString {
     
     let timeStamp = Date().timeIntervalSince1970
     let stringTimestamp = "\(timeStamp)"
     let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
     
     if isTextMessage ?? true {
     
     self.groupChatMessagesRef.child("\(self.documentID ?? "")/lastMessage").setValue("\(self.userFullName ?? "") sent an image")
     
     self.groupChatMessagesRef.child(self.documentID!).child("Messages").child("Message,\(commaTimestamp)").setValue([
     "messageSender": self.userFullName,
     "imageURL": imageURl,
     "timeStamp": commaTimestamp
     ])
     
     for email in self.groupMembers?[1] ?? [] {
     let commaEmail = email.replacingOccurrences(of: ".", with: ",")
     self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID!).setValue([
     "title": self.groupChatTitle,
     "documentID": self.documentID,
     "imageURL": imageURl,
     "lastMessage": "\(self.userFullName ?? "") sent an image",
     "timeStamp": commaTimestamp
     ])
     }
     } else {
     for member in self.groupMembers! {
     let commaEmail = member[1].replacingOccurrences(of: ".", with: ",")
     
     self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/profileImageUrl").setValue(imageURl)
     }
     }
     }
     }
     }
     }*/
}




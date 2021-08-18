//
//  GroupChatViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/25/21.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GrowingTextView
import PhotosUI

class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}

class GroupChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    
    
    
    @IBOutlet weak var textBarStackView: UIStackView!
    @IBOutlet weak var textBarRightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var chatTextBar: UITextField!
    @IBOutlet weak var chatTextBar: GrowingTextView!
    @IBOutlet weak var chatViewNavigationBar: UINavigationItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textBarAndButtonHolder: UIView!
    
    @IBOutlet weak var textBarView: UIView!
    
    //@IBOutlet weak var tableAndTextBarView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pushMessageButton: UIBarButtonItem!
    
    
    let db = Firestore.firestore()
    var user: User! = Firebase.Auth.auth().currentUser
    var commaEmail: String = ""
    var userFullName: String = ""
    var userVenmoName: String = ""
    var ref: DocumentReference? = nil
    var documentID = ""
    var initialBottomConstraint: CGFloat = 0
    var messages: [String:[Message]]  = [:]
    var pushMessages: [Message] = []
    var groupChatTitle: String = ""
    var groupMembers: [[String]] = []
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatByUsersRef = Database.database().reference().child("GroupChatsByUser")
    let usersRef = Database.database().reference().child("users")
    let defaults = UserDefaults.standard
    var heightLoaded = false
    var layoutNum = 0
    var keyArray: [String] = []
    let dateFormatter = DateFormatter()
    var keyboardIsShowing: Bool!
    var unreadPushMessages: [String] = []
    var totalMessages: Int = 0
    let pushMessagesTableView = SelfSizedTableView()
    let imageCache = NSCache<NSString, AnyObject>()
    let cameraButton = UIButton()
    var groupChatImageUrl: String = ""
    var userNickName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commaEmail = user.email!.replacingOccurrences(of: ".", with: ",")
        
        chatTextBar.delegate = self
        
        chatTableView.allowsSelection = false
        
        self.setUpCamerabutton()
        self.setUpSendButton()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableSwipe"), object: nil)
        
        let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        usersRef.child(commaEmail).observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let firstName = value["firstName"] as! String
                let lastName = value["lastName"] as! String
                self.userFullName = "\(firstName) \(lastName)"
                self.userVenmoName = value["venmoName"] as! String
                self.chatTableView.reloadData()
            } else {
                print("No Value")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).child("nickName").observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            if let userNickName = snapshot.value as? String {
                self.userNickName = userNickName
            } else {
                print("No Value")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.keyboardIsShowing = false
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //let displayWidth: CGFloat = self.view.frame.width
        //let displayHeight: CGFloat = self.view.frame.height
        
        /*let docRef = self.db.collection("users").document(self.user!.email!)
         
         docRef.getDocument { (document, error) in
         if let document = document, document.exists {
         let firstName: String = document.data()!["firstName"] as! String
         let lastName: String = document.data()!["lastName"] as! String
         self.userFullName = "\(firstName) \(lastName)"
         } else {
         print("Document does not exist")
         }
         }*/
        
        title = groupChatTitle
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        
        /*chatTableView.register(UINib(nibName: "RegularMessageBody", bundle: nil), forCellReuseIdentifier: "regularMessageCell")*/
        
        chatTableView.register(BubbleMessageBodyCell.self, forCellReuseIdentifier: "regularMessageCell")
        
        chatTableView.register(PictureMessageTableViewCell.self, forCellReuseIdentifier: "pictureMessageCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textBarView.layer.cornerRadius = chatTextBar.bounds.height/2
        textBarView.layer.backgroundColor = UIColor.clear.cgColor
        textBarView.layer.borderWidth = 3
        textBarView.layer.borderColor =
            UIColor.white.cgColor//UIColor(named: "BrandPurpleColor")?.cgColor
        
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        loadMessages()
        setUpPushMessagesTable()
        loadMessages()
        
        
    }
    
    func setUpPushMessagesTable() {
        
        self.view.insertSubview(pushMessagesTableView, aboveSubview: self.chatTableView/*pushMessagesContainerView*/)
        pushMessagesTableView.translatesAutoresizingMaskIntoConstraints = false
        pushMessagesTableView.backgroundColor = .clear
        pushMessagesTableView.separatorStyle = .none
        pushMessagesTableView.register(UINib(nibName: "RegularMessageBody", bundle: nil), forCellReuseIdentifier: "regularMessageCell")
        pushMessagesTableView.isScrollEnabled = false
        pushMessagesTableView.dataSource = self
        pushMessagesTableView.delegate = self
        //pushMessagesTableView.isScrollEnabled = false
        
        let pushMessagesTableViewConstraints = [
            pushMessagesTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            //pushMessagesTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            pushMessagesTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            pushMessagesTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(pushMessagesTableViewConstraints)
        
        /*let pushMessagesContainerView = UIView()
         self.view.insertSubview(pushMessagesContainerView, belowSubview: pushMessagesTableView)
         pushMessagesContainerView.translatesAutoresizingMaskIntoConstraints = false
         pushMessagesContainerView.backgroundColor = .yellow
         pushMessagesContainerView.layer.cornerRadius = 10
         
         let pushMessagesContainerViewConstraints = [
         pushMessagesContainerView.topAnchor.constraint(equalTo: pushMessagesContainerView.topAnchor, constant: -20),
         pushMessagesContainerView.bottomAnchor.constraint(equalTo: pushMessagesTableView.bottomAnchor, constant: 0),
         pushMessagesContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
         pushMessagesContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
         ]
         
         NSLayoutConstraint.activate(pushMessagesContainerViewConstraints)
         */
        
    }
    
    override func viewDidLayoutSubviews() {
        /*if self.layoutNum == 1 {
         self.heightLoaded = true
         self.pushMessagesTableView.reloadData()
         pushMessagesTableView.layoutIfNeeded()
         pushMessagesTableView.frame.size.height = pushMessagesTableViewHeight
         pushMessagesTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
         pushMessagesTableView.heightAnchor.constraint(equalToConstant: 202).isActive = true
         pushMessagesTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
         pushMessagesTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
         pushMessagesTableView.isScrollEnabled = true
         }
         self.layoutNum += 1*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //pushMessagesTableView.isScrollEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.pushMessagesTableView.backgroundColor = .clear
        
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //navigationController?.navigationBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        self.keyboardIsShowing = true
        self.pushMessageButton.image = UIImage(systemName: "pin")
        self.pushMessageButton.tintColor = UIColor(named: K.BrandColors.red)
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        
        bottomConstraint.constant = keyboardFrame + 1
        
        /*if totalMessages <= 5 {
         bottomConstraint.constant = keyboardFrame
         } else {
         if (self.view.bounds.origin.y == 0) {
         self.view.bounds.origin.y += (keyboardFrame - 42)
         }
         }*/
        
        self.textBarRightConstraint.constant = 120
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        self.keyboardIsShowing = false
        
        self.pushMessageButton.image = UIImage(systemName: "ellipsis")
        self.pushMessageButton.tintColor = .systemBlue
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        bottomConstraint.constant = initialBottomConstraint
        
        /*if totalMessages <= 5 {
         bottomConstraint.constant = initialBottomConstraint
         } else {
         self.view.bounds.origin.y = 0
         }*/
        
        self.textBarRightConstraint.constant = 14
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    func setUpCamerabutton() {
        
        let cameraContainerView = UIView()
        self.view.addSubview(cameraContainerView)
        cameraContainerView.translatesAutoresizingMaskIntoConstraints = false
        cameraContainerView.backgroundColor = UIColor(named: K.BrandColors.purple)
        cameraContainerView.center.y = textBarView.center.y
        
        let cameraButtonContainerViewConstraints = [
            cameraContainerView.heightAnchor.constraint(equalToConstant: textBarView.frame.height),
            cameraContainerView.widthAnchor.constraint(equalToConstant: 40),
            cameraContainerView.bottomAnchor.constraint(equalTo: textBarView.bottomAnchor, constant: 0),
            cameraContainerView.leadingAnchor.constraint(equalTo: textBarView.trailingAnchor, constant: 15)
        ]
        
        NSLayoutConstraint.activate(cameraButtonContainerViewConstraints)
        
        cameraContainerView.layer.cornerRadius = textBarView.frame.height/2
        
        cameraContainerView.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.tintColor = .white
        cameraButton.center.y = textBarView.center.y
        let cameraImageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
        let cameraImage = UIImage(systemName: "camera", withConfiguration: cameraImageConfiguration)
        cameraButton.setImage(cameraImage, for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        
        let cameraButtonConstraints = [
            cameraButton.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor, constant: 5),
            cameraButton.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor, constant: -5),
            cameraButton.topAnchor.constraint(equalTo: cameraContainerView.topAnchor, constant: 5),
            cameraButton.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -7),
        ]
        
        NSLayoutConstraint.activate(cameraButtonConstraints)
        
    }
    
    func setUpSendButton() {
        let senderButton = UIButton()
        self.view.addSubview(senderButton)
        senderButton.translatesAutoresizingMaskIntoConstraints = false
        senderButton.tintColor = UIColor(named: K.BrandColors.purple)
        senderButton.center.y = textBarView.center.y
        let cameraImageConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
        let cameraImage = UIImage(systemName: "location.north", withConfiguration: cameraImageConfiguration)
        senderButton.setImage(cameraImage, for: .normal)
        senderButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        
        let cameraButtonConstraints = [
            senderButton.heightAnchor.constraint(equalToConstant: 35),
            senderButton.widthAnchor.constraint(equalToConstant: 35),
            senderButton.bottomAnchor.constraint(equalTo: textBarView.bottomAnchor, constant: 0),
            senderButton.leadingAnchor.constraint(equalTo: cameraButton.trailingAnchor, constant: 12)
        ]
        
        NSLayoutConstraint.activate(cameraButtonConstraints)
        
    }
    
    @objc func cameraButtonPressed() {
        
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 0
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        } else {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            
            self.present(imagePickerController, animated: true)
        }
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            let imageName = NSUUID().uuidString
            let storage = Storage.storage()
            let ref = storage.reference().child("message_images").child(imageName)
            
            if let uploadData = selectedImage.jpegData(compressionQuality: 0.2) {
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
                            
                            self.groupChatMessagesRef.child("\(self.documentID)/lastMessage").setValue("\(self.userFullName) sent an image")
                            
                            self.groupChatMessagesRef.child(self.documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                                "messageSender": self.userFullName,
                                "imageURL": imageURl,
                                "timeStamp": commaTimestamp
                            ])
                            
                            for email in self.groupMembers[1] {
                                let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                                self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).setValue([
                                    "title": self.groupChatTitle,
                                    "documentID": self.documentID,
                                    "imageURL": imageURl,
                                    "lastMessage": "\(self.userFullName) sent an image",
                                    "timeStamp": commaTimestamp
                                ])
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
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
                        let storage = Storage.storage()
                        let ref = storage.reference().child("message_images").child(imageName)
                        
                        if let uploadData = selectedImage.jpegData(compressionQuality: 0.2) {
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
                                        
                                        self?.groupChatMessagesRef.child("\(self!.documentID)/lastMessage").setValue("\(self!.userFullName) sent an image")
                                        
                                        self?.groupChatMessagesRef.child(self!.documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                                            "messageSender": self?.userFullName,
                                            "imageURL": imageURl,
                                            "timeStamp": commaTimestamp
                                        ])
                                        
                                        for email in self?.groupMembers[1] ?? [] {
                                            let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                                            self!.groupChatByUsersRef.child(commaEmail).child("Chats").child(self!.documentID).setValue([
                                                "title": self!.groupChatTitle,
                                                "documentID": self!.documentID,
                                                "imageURL": imageURl,
                                                "lastMessage": "\(self!.userFullName) sent an image",
                                                "timeStamp": commaTimestamp
                                            ])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushButtonPressed(_ sender: UIBarButtonItem) {
        
        if let messageBody = chatTextBar.text, self.keyboardIsShowing == true {
            
            /*let pushMessagesRef = self.groupChatMessagesRef.child(self.documentID).child("pushMessages")
             pushMessagesRef.removeAllObservers()*/
            
            let pushMessageUID = String(Int.random(in: 1...10000000000000))
            
            /*if var unreadPushMessages = defaults.array(forKey: "unreadPushMessages") {
             unreadPushMessages.append(pushMessageUID)
             defaults.setValue(unreadPushMessages, forKey: "unreadPushMessages")
             } else {
             let undreadPushMessages = [pushMessageUID]
             defaults.setValue(undreadPushMessages, forKey: "unreadPushMessages")
             }
             
             let currentUnreadPushMessages = defaults.array(forKey: "unreadPushMessages")*/
            
            
            let timestamp = (Date().timeIntervalSince1970)
            let timestampString = ("\(timestamp)")
            let commaTimestamp =  timestampString.replacingOccurrences(of: ".", with: ",")
            
            self.chatTextBar.text = ""
            
            self.groupChatMessagesRef.child(documentID).child("pushMessages").child(String(pushMessageUID)).setValue([
                "messageSender": userFullName,
                "messageBody": messageBody,
                "timeStamp": commaTimestamp
            ], withCompletionBlock: { err, DatabaseReference in
                if let err = err {
                    print(err)
                } else {
                    self.loadMessages()
                    self.pushMessagesTableView.reloadData()
                }
            })
            
            for email in groupMembers[1] {
                let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                
                self.groupChatByUsersRef.child(commaEmail).child("Chats").child(documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { snapshot in
                    var unreadPushMessages = snapshot.value as? [String] ?? []
                    unreadPushMessages.append(pushMessageUID)
                    
                    if email == self.user.email {
                        self.unreadPushMessages = unreadPushMessages
                    }
                    
                    self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).setValue([
                        "title": self.groupChatTitle,
                        "documentID": self.documentID,
                        "lastMessage": messageBody,
                        "timeStamp": commaTimestamp,
                        "unreadPushMessages": unreadPushMessages
                    ])
                }
            }
        } else if keyboardIsShowing == false{
            performSegue(withIdentifier: "toGroupChatInfo", sender: self)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GroupChatInfoViewController {
            let vc = segue.destination as! GroupChatInfoViewController
            vc.documentID = self.documentID
            vc.groupMembers = self.groupMembers
            vc.groupChatTitle = self.groupChatTitle
            vc.userFullName = self.userFullName
            vc.groupChatImageUrl = self.groupChatImageUrl
            vc.userNickName = self.userNickName ?? userFullName
        }
    }
    
    @objc func readButtonPressed(_ sender: UIButton) {
        let pushMessageUID = self.unreadPushMessages[sender.tag]
        self.unreadPushMessages = self.unreadPushMessages.filter { $0 != pushMessageUID }
        let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).child("unreadPushMessages").setValue(self.unreadPushMessages) { err, DatabaseReference in
            if let err = err {
                print(err)
            } else {
                if self.unreadPushMessages.count == 0 {
                    self.pushMessages = []
                    
                    /*NSLayoutConstraint.deactivate(self.pushMessagesContainerViewConstraintsFullScreen)
                     NSLayoutConstraint.deactivate(self.pushMessagesContainerViewConstraintsFitted)
                     NSLayoutConstraint.activate(self.pushMessagesContainerViewConstraintsZero)*/
                    self.pushMessagesTableView.reloadData()
                } else {
                    self.loadMessages()
                }
            }
        }
    }
    
    @objc func sendButtonPressed() {
        if chatTextBar.text != "" {
            let messageBody = "\(self.userFullName): \(chatTextBar.text!)"
            
            let timeStamp = Date().timeIntervalSince1970
            let stringTimestamp = "\(timeStamp)"
            let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
            self.chatTextBar.text = ""
            
            self.groupChatMessagesRef.child("\(documentID)/lastMessage").setValue(messageBody)
            self.groupChatMessagesRef.child("\(documentID)/senderEmail").setValue(self.user.email!)
            self.groupChatMessagesRef.child("\(documentID)/timeStamp").setValue(commaTimestamp)
            
            let decimalRange = messageBody.rangeOfCharacter(from: CharacterSet.decimalDigits)
            
            let messageBodyHasNumbers = (decimalRange != nil)
            
            if messageBody.contains("Venmo") && messageBodyHasNumbers {
                self.groupChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                    "messageSender": userFullName,
                    "messageSenderNickName": self.userNickName ?? self.userFullName,
                    "messageBody": messageBody,
                    "timeStamp": commaTimestamp,
                    "venmoName": self.userVenmoName
                ])
            } else {
                self.groupChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                    "messageSender": userFullName,
                    "messageSenderNickName": self.userNickName ?? self.userFullName,
                    "messageBody": messageBody,
                    "timeStamp": commaTimestamp,
                ])
            }
            
            /*db.collection("GroupChatMessages").document(documentID).collection("Messages").document("Message.\(Date().timeIntervalSince1970)").setData([
             "messageSender": userFullName,
             "messageBody": messageBody,
             "timeStamp": timeStamp
             ]) { err in
             if let err = err {
             print("Error writing document: \(err)")
             } else {
             print("Document successfully written!")
             }
             }*/
            
            for member in groupMembers {
                let email = member[1]
                let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                
                self.groupChatByUsersRef.child(commaEmail).child("Chats").child(documentID).setValue([
                    "title": groupChatTitle,
                    "documentID": documentID,
                    "profileImageUrl": self.groupChatImageUrl,
                    "notificationsEnabled": true
                    
                 //"lastMessage": messageBody,
                 //"timeStamp": commaTimestamp,
                 //"readNotification": false
                 ])
                
                self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/lastMessage").setValue(messageBody)
                self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/timeStamp").setValue(commaTimestamp)
                self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/readNotification").setValue(false)

                
                /*usersRef.child(commaEmail).child("profileImageUrl").observe(DataEventType.value) { Snapshot in
                    let profileImageUrl = Snapshot.value as? String
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/profileImageUrl").setValue(profileImageUrl)
                }*/
            
                /*db.collection("GroupChatsByUser").document(email).collection("Chats").document(documentID).setData([
                 "title": groupChatTitle,
                 "documentID": documentID,
                 "lastMessage": messageBody,
                 "timeStamp": timeStamp
                 ]) { err in
                 if let err = err {
                 print("Error writing document: \(err)")
                 } else {
                 print("Document successfully written!")
                 }
                 }*/
            }
        }
    }
    
    
    /*func loadMessages() {
     db.collection("GroupChatMessages").document(documentID).collection("Messages").order(by: "timeStamp").addSnapshotListener { querySnapshot, err in
     if let err = err {
     print("Error getting documents: \(err)")
     } else {
     self.messages = []
     if querySnapshot!.documents.isEmpty {
     print ("No GroupChatMessage documents")
     } else {
     for document in querySnapshot!.documents {
     print(document)
     let messageSender = document.data()["messageSender"] as! String
     let messageBody = document.data()["messageBody"] as! String
     let timeStamp =  document.data()["timeStamp"] as? Double ?? 0.0
     
     let message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp)
     self.messages.append(message)
     DispatchQueue.main.async {
     self.chatTableView.reloadData()
     let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
     self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
     
     }
     }
     }
     }
     }
     }*/
    
    func loadMessages() {
        let MessagesRef = groupChatMessagesRef.child(documentID).child("Messages")
        
        let userBadgeCountRef = usersRef.child(self.commaEmail).child("badgeCount")
        
        let conversationBadgeCountRef = groupChatByUsersRef.child(self.commaEmail).child("Chats").child(self.documentID).child("badgeCount")
        
        conversationBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
            self.groupChatByUsersRef.child("\(self.commaEmail)/Chats/\(self.documentID)/readNotification").setValue(true)
        })
        
        MessagesRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.messages = [:]
            self.keyArray = []
            for value in postDict.values {
                if let messageSender = value.object(forKey: "messageSender")! as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    let messageSenderNickName = value.object(forKey: "messageSenderNickName") as? String ?? messageSender
                    if let message = value.object(forKey: "messageBody") as? String {
                        self.totalMessages += 1
                        let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                        
                        var messageBody = ""
                        if message.contains(":") {
                            let messageArray = message.components(separatedBy: ": ")
                            if messageArray.count >= 2 {
                                messageBody = messageArray[1]
                            } else {
                                messageBody = message
                            }
                        } else {
                            messageBody = message
                        }
                        
                        var message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: nil, messageSenderNickName: messageSenderNickName)
                        
                        if let venmoName = value.object(forKey: "venmoName") as? String {
                            message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: nil, venmoName: venmoName, messageSenderNickName: messageSenderNickName)
                        }
                        
                        self.dateFormatter.dateFormat = "MM/dd/yyyy"
                        let messageDate = self.dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
                        
                        if self.messages[messageDate] != nil {
                            var messageArray = self.messages[messageDate]!
                            messageArray.append(message)
                            self.messages.updateValue(messageArray, forKey: messageDate)
                        } else {
                            self.messages[messageDate] = [message]
                            self.keyArray.append(messageDate)
                            self.keyArray = self.keyArray.sorted(by: { $0 < $1 })
                        }
                        
                        self.chatTableView.reloadData()
                        DispatchQueue.main.async() {
                            /*let indexPath = IndexPath(row: self.messages[self.keyArray.last!]!.count - 1, section: self.keyArray.count - 1)
                             self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)*/
                        }
                    } else if let imageURL = value.object(forKey: "imageURL") as? String {
                        print("Image")
                        self.totalMessages += 1
                        let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                        
                        let message = Message(messageSender: messageSender, messageBody: nil, timeStamp: timeStamp, pushMessageUID: nil, imageURL: imageURL, messageSenderNickName: messageSenderNickName)
                        
                        self.dateFormatter.dateFormat = "MM/dd/yyyy"
                        let messageDate = self.dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
                        
                        if self.messages[messageDate] != nil {
                            var messageArray = self.messages[messageDate]!
                            messageArray.append(message)
                            self.messages.updateValue(messageArray, forKey: messageDate)
                        } else {
                            self.messages[messageDate] = [message]
                            self.keyArray.append(messageDate)
                            self.keyArray = self.keyArray.sorted(by: { $0 < $1 })
                        }
                        
                        self.chatTableView.reloadData()
                        DispatchQueue.main.async() {
                            let indexPath = IndexPath(row: self.messages[self.keyArray.last!]!.count - 1, section: self.keyArray.count - 1)
                            //self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        })
        
        userBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
            let postIntAsString = snapshot.value! as! String
            let postInt = Int(postIntAsString)
            UIApplication.shared.applicationIconBadgeNumber = postInt!
        })
        
        let pushMessagesRef = groupChatMessagesRef.child(documentID).child("pushMessages")
        
        let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { snapshot in
            self.unreadPushMessages = snapshot.value as? [String] ?? []
            
            pushMessagesRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                self.pushMessages = []
                var count = 0
                for (key,value) in postDict {
                    if self.unreadPushMessages.contains(key) {
                        count += 1
                        if let messageSender = value.object(forKey: "messageSender")! as? String, let messageBody = value.object(forKey: "messageBody") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                            let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                            let message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: key)
                            self.pushMessages.append(message)
                            DispatchQueue.main.async {
                                self.pushMessagesTableView.reloadData()
                                /*let indexPath = IndexPath(row: self.pushMessages.count - 1, section: 0)
                                 self.pushMessagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)*/
                            }
                            
                        }
                    }
                }
                
                if count == 0 {
                    self.pushMessagesTableView.backgroundColor = .clear
                } else {
                    self.pushMessagesTableView.backgroundColor = .red
                }
            }
            
            DispatchQueue.main.async {
                self.setUpPushMessagesTable()
                self.pushMessagesTableView.reloadData()
                /*if self.pushMessages.count >= 1 {
                 let indexPath = IndexPath(row: self.pushMessages.count - 1, section: 0)
                 self.pushMessagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                 }*/
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            
            guard let navigationController = self.navigationController else { return }
            var navigationArray = navigationController.viewControllers
            
            if navigationArray.count == 2 {
                navigationArray.remove(at: navigationArray.count - 1)
                self.navigationController?.viewControllers = navigationArray
            }
            
            let commaEmail = user.email!.replacingOccurrences(of: ".", with: ",")
            
            let conversationBadgeCountRef = groupChatByUsersRef.child(commaEmail).child("Chats").child(documentID).child("badgeCount")
            
            conversationBadgeCountRef.removeAllObservers()
            
            self.usersRef.removeAllObservers()
        }
    }
}







extension GroupChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.pushMessagesTableView {
            self.loadMessages()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.pushMessagesTableView {
            return pushMessages.count
        } else {
            var reversedKeyArray: [String] = []
            
            for value in self.keyArray.reversed() {
                reversedKeyArray.append(value)
            }
            
            let key = reversedKeyArray[section]
            return messages[key]!.count
            
            /*let key = keyArray[section]
             return messages[key]!.count*/
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.pushMessagesTableView {
            let cell = pushMessagesTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! RegularMessageBody
            
            let sortedMessages = self.pushMessages.sorted(by: { $0.timeStamp < $1.timeStamp })
            
            let message = sortedMessages[indexPath.row]
            
            cell.emailLabel.text = message.messageSender
            cell.messageBody.text = message.messageBody
            cell.pushMessageUID = message.pushMessageUID!
            cell.readbutton.tag = indexPath.row
            cell.readbutton.addTarget(self, action: #selector(self.readButtonPressed(_:)), for: .touchUpInside)
            
            cell.contentView.backgroundColor = UIColor.red
            return cell
            
        } else {
            var reversedKeyArray: [String] = []
            
            for value in self.keyArray.reversed() {
                reversedKeyArray.append(value)
            }
            
            let key = reversedKeyArray[indexPath.section]
            
            let sortedMessages = self.messages[key]!.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let message = sortedMessages[indexPath.row]
            
            
            
            if message.imageURL != "" {
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "pictureMessageCell", for: indexPath) as! PictureMessageTableViewCell
                
                cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
                
                if message.messageSender == userFullName {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                
                cell.imageURL = message.imageURL!
                
                let imageURL = message.imageURL! as NSString
                
                if let cachedImage = self.imageCache.object(forKey: imageURL) {
                    cell.messageImageView.image = cachedImage as? UIImage
                } else {
                    DispatchQueue.global().async { [weak self] in
                        let URL = URL(string: message.imageURL!)
                        if let data = try? Data(contentsOf: URL!) {
                            if let image = UIImage(data: data) {
                                let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                DispatchQueue.main.async {
                                    self!.imageCache.setObject(image, forKey: imageURL)
                                    cell.imageHeight = imageHeight
                                    cell.imageWidth = 300
                                    cell.messageImageView.image = image
                                }
                            }
                        }
                    }
                }
                
                cell.emailLabel.text = message.messageSenderNickName
                
                cell.isGroupMessage = true
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
                
                
            } else {
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! BubbleMessageBodyCell
                
                if let messageBody = message.messageBody {
                    
                    cell.messageBody.text = messageBody
                    
                    let decimalRange = messageBody.rangeOfCharacter(from: CharacterSet.decimalDigits)
                    
                    let messageBodyHasNumbers = (decimalRange != nil)
                    
                    if messageBody.contains("Venmo") && messageBodyHasNumbers {
                        if message.messageSender != userFullName {
                            cell.isVenmoRequest = true
                            
                            
                            let numString = messageBody.numArray.joined(separator: " ")
                            let numArray = numString.split(separator: " ").map(String.init)
                            
                            if numArray.count == 1 {
                                cell.venmoAmount = numArray.first!
                            }
                            
                            cell.venmoName = message.venmoName
                            
                            if message.messageSender == userFullName {
                                cell.isIncoming = false
                            } else {
                                cell.isIncoming = true
                            }
                            
                        } else {
                            cell.isVenmoRequest = false
                            
                            if message.messageSender == userFullName {
                                cell.isIncoming = false
                            } else {
                                cell.isIncoming = true
                            }
                            
                            cell.bubbleView.layer.borderColor = UIColor(named: "BrightBlue")?.cgColor
                            
                        }
                    } else {
                        cell.isVenmoRequest = false
                        
                        if message.messageSender == userFullName {
                            cell.isIncoming = false
                        } else {
                            cell.isIncoming = true
                        }
                    }
                } else {
                    cell.messageBody.text = ""
                }
                
                cell.emailLabel.text = message.messageSenderNickName
                
                cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
                
                cell.isGroupMessage = true
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
        }
    }
    
    func checkCellPosition(sortedMessages: [Message], indexPathRow: Int) -> String {
        
        if (indexPathRow == 0 && indexPathRow == sortedMessages.count - 1) {
            //let message = sortedMessages[indexPath.row]
            return "notOfGroup"
        }
        // if first message in section
        else if (indexPathRow == 0) {
            let message = sortedMessages[indexPathRow]
            let nextMessage = sortedMessages[indexPathRow + 1]
            
            if message.messageSender == nextMessage.messageSender {
                return "groupEnd"
            } else {
                return "notOfGroup"
            }
            
            //if last message of section
        } else if (indexPathRow == sortedMessages.count - 1) {
            let previousMessage = sortedMessages[indexPathRow - 1]
            let message = sortedMessages[indexPathRow]
            
            if previousMessage.messageSender == message.messageSender {
                return "groupStart"
            } else {
                return "notOfGroup"
            }
            
            //if in the middle of section
        } else {
            let previousMessage = sortedMessages[indexPathRow - 1]
            let message = sortedMessages[indexPathRow]
            let nextMessage = sortedMessages[indexPathRow + 1]
            
            if previousMessage.messageSender == message.messageSender {
                if message.messageSender == nextMessage.messageSender {
                    return "groupMiddle"
                } else {
                    return "groupStart"
                }
            } else if (message.messageSender == nextMessage.messageSender){
                return"groupEnd"
            } else {
                return "notOfGroup"
            }
        }
        
        return "notOfGroup"
    }
    
    /*func ImageCell(cell: BubbleMessageBodyCell, message: Message) {
     cell.imageURL = message.imageURL!
     cell.isOfImage = true
     
     let imageURL = message.imageURL! as NSString
     
     if let cachedImage =
     self.imageCache.object(forKey: imageURL) {
     cell.messageImageView.image = cachedImage as? UIImage
     } else {
     let URL = URL(string: message.imageURL!)
     
     URLSession.shared.dataTask(with: URL!) { (data, response, error) in
     
     if error != nil {
     print("ERROR")
     print(error!)
     return
     }
     
     DispatchQueue.main.async {
     if let downloadedImage = UIImage(data: data!) {
     self.imageCache.setObject(downloadedImage, forKey: imageURL)
     }
     }
     
     }
     }
     }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.pushMessagesTableView {
            return 1
        } else {
            return keyArray.count
        }
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     if tableView == pushMessagesTableView {
     return CGFloat(0)
     } else {
     return 20
     }
     }*/
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == pushMessagesTableView {
            return 0
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == chatTableView {
            let specificSection = self.keyArray[section]
            
            if let firstMessageInSection = self.messages[specificSection]?.first {
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let date = Date(timeIntervalSince1970: firstMessageInSection.timeStamp)
                let dateString = dateFormatter.string(from: date)
                
                let headerLabel = UILabel()
                headerLabel.text = dateString
                headerLabel.textColor = .white
                headerLabel.textAlignment = .center
                headerLabel.translatesAutoresizingMaskIntoConstraints = false
                headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
                
                let containerView = UIView()
                containerView.addSubview(headerLabel)
                containerView.backgroundColor = .black
                
                let headerViewConstraints = [
                    //headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                    //headerLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor),
                    headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    headerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
                ]
                
                NSLayoutConstraint.activate(headerViewConstraints)
                
                /*let containerViewConstraints = [
                 containerView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: -10)
                 ]*/
                
                containerView.transform = CGAffineTransform(scaleX: 1, y: -1)
                return containerView
            }
            return nil
        }
        return nil
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     if tableView == chatTableView {
     let specificSection = self.keyArray[section]
     
     if let firstMessageInSection = self.messages[specificSection]?.first {
     dateFormatter.dateFormat = "MM/dd/yyyy"
     let date = Date(timeIntervalSince1970: firstMessageInSection.timeStamp)
     let dateString = dateFormatter.string(from: date)
     
     let headerLabel = UILabel()
     headerLabel.backgroundColor = .clear
     headerLabel.text = dateString
     headerLabel.textColor = .white
     headerLabel.textAlignment = .center
     headerLabel.translatesAutoresizingMaskIntoConstraints = false
     headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
     
     let containerView = UIView()
     containerView.addSubview(headerLabel)
     containerView.backgroundColor = .black
     
     let headerViewConstraints = [
     //headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
     //headerLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor),
     headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
     headerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
     ]
     
     NSLayoutConstraint.activate(headerViewConstraints)
     
     /*let containerViewConstraints = [
     containerView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: -10)
     ]*/
     
     containerView.transform = CGAffineTransform(scaleX: 1, y: -1)
     return containerView
     }
     return nil
     }
     return nil
     }*/
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     if tableView == self.pushMessagesTableView {
     if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
     if indexPath == lastVisibleIndexPath {
     let height = self.pushMessagesTableView.contentSize.height
     NSLayoutConstraint.deactivate(pushMessagesContainerViewConstraintsFitted)
     self.pushMessagesContainerViewConstraintsFitted = [
     pushMessagesContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
     pushMessagesContainerView.heightAnchor.constraint(equalToConstant: height + CGFloat(12.3333)),
     pushMessagesContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
     pushMessagesContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
     ]
     }
     }
     }
     }*/
}

extension String {
    public var numArray: [String] {
        let characterSet = CharacterSet(charactersIn: "0123456789.").inverted
        return components(separatedBy: characterSet)
        
    }
}







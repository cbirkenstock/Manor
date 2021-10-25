//
//  ChatViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/14/21.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GrowingTextView
import PhotosUI
import Amplify
import AmplifyPlugins

class ChatViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textBarRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    //@IBOutlet weak var chatTextBar: UITextField!
    @IBOutlet weak var chatTextBar: GrowingTextView!
    
    @IBOutlet weak var chatViewNavigationBar: UINavigationItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textBarAndButtonHolder: UIView!
    
    @IBOutlet weak var textBarView: UIView!
    
    @IBOutlet weak var tableAndTextBarView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pushMessageButton: UIBarButtonItem!
    let dateFormatter = DateFormatter()
    
    
    let db = Firestore.firestore()
    var user: User! = Firebase.Auth.auth().currentUser
    var ref: DocumentReference? = nil
    var documentID = ""
    var initialBottomConstraint: CGFloat = 0
    var userFullName: String = ""
    var messages: [String:[Message]]  = [:]
    var otherUserFullName: String = ""
    var otherUserEmail: String = ""
    let chatMessagesRef = Database.database().reference().child("ChatMessages")
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    let usersRef = Database.database().reference().child("users")
    var commaDocumentName: String = ""
    var commaUserEmail: String = ""
    var commaOtherUserEmail: String = ""
    var keyArray: [String] = []
    var totalMessages: Int = 0
    var venmoUserName: String = ""
    var otherUserVenmoName: String = ""
    var userProfileImageUrl: String = ""
    var otherUserProfileImageUrl: String = ""
    let cameraButton = UIButton()
    let photoManager = PhotoManagerViewController()
    let imageCache = NSCache<NSString, AnyObject>()
    var isNewChat: Bool = false
    //var conversationBadgeCountHandler: UInt?
    var photoCount: Int = 0
    var chatImagesArray: [String] = []
    var currentChatImageDictionary: [String:Data] = [:]
    let defaults = UserDefaults.standard
    var barButtonProfileImageUrl: String = ""
    //var barButtonProfileImage: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.contentInset.top = -75
        
        if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") as? [String: Data] {
            self.currentChatImageDictionary = chatImageDictionary
            //self.defaults.setValue([:], forKey: "\(self.documentID) photos")
        } else {
            self.defaults.setValue([:], forKey: "\(self.documentID) photos")
        }
        
        let otherUserCommaEmail = self.otherUserEmail.replacingOccurrences(of: ".", with: ",")
        
        usersRef.child(otherUserCommaEmail).observeSingleEvent(of: DataEventType.value) { snapshot in
            let postDict = snapshot.value as? [String: Any] ?? [:]
            self.otherUserVenmoName = postDict["venmoName"] as? String ?? ""
            self.otherUserProfileImageUrl = postDict["profileImageUrl"] as? String ?? "default"
        }
        
        
        
        chatTableView.allowsSelection = false
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableSwipe"), object: nil)
        //postNotificationName("enableSwipe", object: nil)
        
        self.chatTableView.isHidden = false
        //self.textBarAndButtonHolder.isHidden = false
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = UIColor(named: "WarmBlack")
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        navigationController?.navigationBar.subviews.first?.alpha = 0.99
        
        if let profileImageDictionary = self.defaults.dictionary(forKey: "contactPictures") {
            if let storedImageData = profileImageDictionary[self.barButtonProfileImageUrl] as? Data {
            
                let profileImageContainerView = UIImageView()
                profileImageContainerView.translatesAutoresizingMaskIntoConstraints = false
                profileImageContainerView.backgroundColor = UIColor(named: "WarmBlack")
                profileImageContainerView.center.y = textBarView.center.y
                profileImageContainerView.clipsToBounds = true
                profileImageContainerView.image = UIImage(data: storedImageData)
                
                let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
                
                let profileImageContainerViewConstraints = [
                    profileImageContainerView.heightAnchor.constraint(equalToConstant: navbarHeight - 1),
                    profileImageContainerView.widthAnchor.constraint(equalToConstant: navbarHeight - 1),
                ]
                
                NSLayoutConstraint.activate(profileImageContainerViewConstraints)
                
                profileImageContainerView.layer.cornerRadius = (navbarHeight - 1)/2
                
                let profileImageButton = UIButton()
                profileImageContainerView.addSubview(profileImageButton)
                profileImageButton.translatesAutoresizingMaskIntoConstraints = false
                profileImageButton.tintColor = .white
                profileImageButton.center.y = textBarView.center.y
                /*let pinImageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
                let pinImage = UIImage(systemName: "pin", withConfiguration: pinImageConfiguration)*/
                //profileImageButton.setImage(UIImage(data: storedImageData), for: .normal)
                profileImageButton.addTarget(self, action: #selector(pushButtonPressed), for: .touchUpInside)
                
                let pinButtonContstraints = [
                    profileImageButton.leadingAnchor.constraint(equalTo: profileImageContainerView.leadingAnchor, constant: 0),
                    profileImageButton.trailingAnchor.constraint(equalTo: profileImageContainerView.trailingAnchor, constant: 0),
                    profileImageButton.topAnchor.constraint(equalTo: profileImageContainerView.topAnchor, constant: 0),
                    profileImageButton.bottomAnchor.constraint(equalTo: profileImageContainerView.bottomAnchor, constant: 0),
                ]
                
                NSLayoutConstraint.activate(pinButtonContstraints)
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImageContainerView)
            }
            
        }
        
        /*let navigationBar = navigationController!.navigationBar
         navigationBar.barTintColor = UIColor.clear
         
         let navigationBarAppearence = UINavigationBarAppearance()
         navigationBarAppearence.shadowColor = .clear
         navigationBar.scrollEdgeAppearance = navigationBarAppearence*/
        
        
        
        
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        
        //pushMessageButton.isEnabled = false
        //pushMessageButton.tintColor = UIColor.clear
        
        
        
        commaUserEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        commaOtherUserEmail = otherUserEmail.replacingOccurrences(of: ".", with: ",")
        
        commaDocumentName = documentID.replacingOccurrences(of: ".", with: ",")
        
        initialBottomConstraint = bottomConstraint.constant
        
        let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        usersRef.child(commaEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let firstName = value["firstName"] as? String ?? ""
                let lastName = value["lastName"] as? String ?? ""
                self.userFullName = "\(firstName) \(lastName)"
                self.venmoUserName = value["venmoName"] as? String ?? ""
                self.userProfileImageUrl = value["profileImageUrl"] as? String ?? "default"
                self.chatTableView.reloadData()
            } else {
                print("No Value")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
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
        
        title = otherUserFullName
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        
        //chatTableView.register(UINib(nibName: "RegularMessageBody", bundle: nil), forCellReuseIdentifier: "regularMessageCell")
        
        chatTableView.register(BubbleMessageBodyCell.self, forCellReuseIdentifier: "regularMessageCell")
        
        chatTableView.register(PictureMessageTableViewCell.self, forCellReuseIdentifier: "pictureMessageCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textBarView.layer.cornerRadius = chatTextBar.bounds.height/2
        textBarView.layer.backgroundColor = UIColor.clear.cgColor
        textBarView.layer.borderWidth = 1
        textBarView.layer.borderColor =
        UIColor.white.cgColor//UIColor(named: "BrandPurpleColor")?.cgColor
        
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.setUpCamerabutton()
        self.setUpSendButton()
        
        loadMessages()
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
        self.photoManager.commaDocumentName = self.commaDocumentName
        self.photoManager.otherUserFullName = self.otherUserFullName
        self.photoManager.otherUserProfileImageUrl = self.otherUserProfileImageUrl
        self.photoManager.userProfileImageUrl = self.userProfileImageUrl
        self.photoManager.commaOtherUserEmail = self.commaOtherUserEmail
        self.photoManager.userFullName = self.userFullName
        self.photoManager.setUpCameraPicker(viewController: self, desiredPicker: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        photoManager.processPickerResultOld(imagePicker: picker, info: info, isTextMessage: true, isGroupMessage: false, isEventChat: false)
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        photoManager.processPickerResultsPHP(imagePicker: picker, results: results, isGroupMessage: false, isEventChat: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideNavigationBar"), object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        for array in navigationArray {
        }
        if navigationArray.count == 3 {
            navigationArray.remove(at: navigationArray.count - 2)
            self.navigationController?.viewControllers = navigationArray
        }
        
        // Hide the navigation bar on the this view controller
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //navigationController?.navigationBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //pushMessageButton.isEnabled = true
        //pushMessageButton.tintColor = UIColor(named: K.BrandColors.red)
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        
        bottomConstraint.constant = keyboardFrame
        
        /*if totalMessages <= 5 {
         bottomConstraint.constant = keyboardFrame
         } else {
         if (self.view.bounds.origin.y == 0) {
         //self.stackView.bounds.origin.y += (keyboardFrame - 42)
         // print(self.view.bounds.origin.y)
         self.view.bounds.origin.y += (keyboardFrame - 42)
         //print(self.view.bounds.origin.y)
         }
         }*/
        
        self.textBarRightConstraint.constant = 120
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //pushMessageButton.isEnabled = false
        //pushMessageButton.tintColor = UIColor.clear
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        if totalMessages <= 5 {
            bottomConstraint.constant = initialBottomConstraint
        } else {
            self.view.bounds.origin.y = 0
        }
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func pushButtonPressed(_ sender: UIBarButtonItem) {
        /*if let messageBody = chatTextBar.text {
         
         let timeStamp = (Date().timeIntervalSince1970)
         let timeStampString = ("\(timeStamp)")
         let commaTimeStamp =  timeStampString.replacingOccurrences(of: ".", with: ",")
         
         self.chatTextBar.text = ""
         
         
         self.chatMessagesRef.child(commaDocumentName).child("pushMessages").child(commaTimeStamp).setValue([
         "messageSender": userFullName,
         "messageBody": messageBody,
         "timeStamp": timeStamp
         ])
         }*/
        
    }
    @IBAction func sendButtonPressed(_ sender: Any) {
        if chatTextBar.text! != "" {
            
            let messageBody = chatTextBar.text!
            
            let timeStamp = Date().timeIntervalSince1970
            let timeStampString = ("\(timeStamp)")
            
            let commaTimeStamp =  timeStampString.replacingOccurrences(of: ".", with: ",")
            //let commaUserEmail = user.email?.replacingOccurrences(of: ".", with: ",")
            self.chatTextBar.text = ""
            
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
            
            self.chatMessagesRef.child(commaDocumentName).child("Messages").child(commaTimeStamp).setValue([
                "messageSender": userFullName,
                "messageBody": messageBody,
                "timeStamp": timeStamp
            ])
            
            
            /*db.collection("ChatMessages").document(documentName).collection("Messages").document("Message.\(Date().timeIntervalSince1970)").setData([
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
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/senderEmail").setValue(commaUserEmail)
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/lastMessage").setValue(messageBody)
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/timeStamp").setValue(timeStamp)
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/title").setValue(self.otherUserFullName)
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/profileImageUrl").setValue(self.otherUserProfileImageUrl)
            
            self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/readNotification").setValue(true)
            
            /*db.collection("ChatsByUser").document("\(String(describing: self.user!.email!))").collection("Chats").document(documentName).setData([
             "title": self.otherUserFullName,
             "senderEmail": self.user!.email!,
             "lastMessage": messageBody,
             "timeStamp": timeStamp
             ]) { err in
             if let err = err {
             print("Error writing document: \(err)")
             } else {
             print("Document successfully written!")
             }
             }*/
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/senderEmail").setValue(commaUserEmail)
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/lastMessage").setValue(messageBody)
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/timeStamp").setValue(timeStamp)
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/title").setValue(self.userFullName)
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/readNotification").setValue(false)
            
            self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/profileImageUrl").setValue(self.userProfileImageUrl)
            
            /*db.collection("ChatsByUser").document("\(self.otherUserEmail)").collection("Chats").document(documentName).setData([
             "title": userFullName,
             "senderEmail": self.user!.email!,
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
    
    
    func loadMessages() {
        self.chatTableView.isHidden = false
        
        let userMessagesRef = chatMessagesRef.child(commaDocumentName).child("Messages")
        
        let conversationBadgeCountRef = chatsByUserRef.child(commaUserEmail).child("Chats").child(commaDocumentName).child("badgeCount")
        
        let userBadgeCountRef = usersRef.child(commaUserEmail).child("badgeCount")
        
        let commaUserEmail = self.user.email?.replacingOccurrences(of: ".", with: ",")
        
        conversationBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
            self.chatsByUserRef.child("\(commaUserEmail!)/Chats/\(self.commaDocumentName)/readNotification").setValue(true)
        })
        
        userMessagesRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.messages = [:]
            self.keyArray = []
            var myKeys: [String] = postDict.map{String($0.key)}
            myKeys.sort {
                $1 < $0
            }
            for key in myKeys {
                let value = postDict[key]!
                if let messageSender = value.object(forKey: "messageSender")! as? String, let timeStamp = value.object(forKey: "timeStamp") as? Double {
                    self.totalMessages += 1
                    if let messageBody = value.object(forKey: "messageBody") as? String {
                        let message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: nil)
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
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        DispatchQueue.main.async {
                            //let indexPath = IndexPath(row: self.messages[self.keyArray.last!]!.count - 1, section: self.keyArray.count - 1)
                            //self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            
                        }
                    } else if let imageURL = value.object(forKey: "imageURL") as? String {
                        
                        let imageHeight = value.object(forKey: "imageHeight") as? Double ?? 400
                        let imageWidth = value.object(forKey: "imageWidth") as? Double ?? 300
                        
                        self.totalMessages += 1
                        
                        let message = Message(messageSender: messageSender, messageBody: nil, timeStamp: timeStamp, pushMessageUID: nil, imageURL: imageURL, messageSenderNickName: nil, imageWidth: imageWidth, imageHeight: imageHeight)
                        
                        self.dateFormatter.dateFormat = "MM/dd/yyyy"
                        let messageDate = self.dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
                        
                        if self.messages[messageDate] != nil {
                            var messageArray = self.messages[messageDate]
                            messageArray!.append(message)
                            self.messages.updateValue(messageArray!, forKey: messageDate)
                        } else {
                            self.messages[messageDate] = [message]
                            self.keyArray.append(messageDate)
                            self.keyArray = self.keyArray.sorted(by: { $0 < $1 })
                        }
                        
                        if self.photoCount < 30 && myKeys.contains(key){
                            self.chatImagesArray.append(imageURL)
                            self.photoCount += 1
                        }
                        
                        self.chatTableView.reloadData()
                        DispatchQueue.main.async() {
                            //let indexPath = IndexPath(row: self.messages[self.keyArray.last!]!.count - 1, section: self.keyArray.count - 1)
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
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showNavigationBar"), object: nil)
            
            guard let navigationController = self.navigationController else { return }
            var navigationArray = navigationController.viewControllers
            
            if navigationArray.count == 2 {
                navigationArray.remove(at: navigationArray.count - 1)
                self.navigationController?.viewControllers = navigationArray
            }
            
            let conversationBadgeCountRef = chatsByUserRef.child(commaUserEmail).child("Chats").child(commaDocumentName).child("badgeCount")
            
            conversationBadgeCountRef.removeAllObservers()
            
            let userMessagesRef = chatMessagesRef.child(commaDocumentName).child("Messages")
            
            userMessagesRef.removeAllObservers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
        
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var reversedKeyArray: [String] = []
        
        for value in self.keyArray.reversed() {
            reversedKeyArray.append(value)
        }
        
        let key = reversedKeyArray[section]
        return messages[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reversedKeyArray: [String] = []
        
        for value in self.keyArray.reversed() {
            reversedKeyArray.append(value)
        }
        
        let key = reversedKeyArray[indexPath.section]
        
        let sortedMessages = self.messages[key]!.sorted(by: { $0.timeStamp > $1.timeStamp })
        
        let message = sortedMessages[indexPath.row]
        
        if indexPath.row < sortedMessages.count - 2 {
            let message2 = sortedMessages[indexPath.row + 1]
            if message2.imageURL != "" {
                let NSImageURL = message2.imageURL! as NSString
                //if let _ = self.imageCache.object(forKey: imageURL) {
                //} else {
                if let _ = self.imageCache.object(forKey: NSImageURL) {
                    print("already contained")
                } else if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") {
                    if let storedImageData = chatImageDictionary[message2.imageURL!] as? Data {
                        print("already contained")
                        self.imageCache.setObject(UIImage(data: storedImageData)!, forKey: NSImageURL as NSString)
                    }
                } else {
                    Amplify.Storage.downloadData(key: message2.imageURL!) { result in
                        switch result {
                        case .success(let data):
                            print("Success downloading image", data)
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.imageCache.setObject(image, forKey: NSImageURL)
                                    if self.chatImagesArray.contains(message2.imageURL!) {
                                        self.currentChatImageDictionary[message2.imageURL!] = data
                                        self.defaults.setValue(self.currentChatImageDictionary, forKey: "\(self.documentID) photos")
                                        print("currentImageDictionary")
                                        print(self.currentChatImageDictionary.count)
                                        print(self.currentChatImageDictionary.keys)
                                    }
                                }
                            }
                        case .failure(let error):
                            print("failure downloading image", error)
                        }
                    }
                }
            }
            
            /*let message3 = sortedMessages[indexPath.row + 1]
             if message3.imageURL != "" {
             let imageURL = message3.imageURL!
             let NSImageURL = message3.imageURL! as NSString
             //if let _ = self.imageCache.object(forKey: imageURL) {
             //} else {
             if let _ = self.imageCache.object(forKey: NSImageURL) {
             print("already contained")
             } else {
             Amplify.Storage.downloadData(key: message3.imageURL!) { result in
             switch result {
             case .success(let data):
             print("Success downloading image", data)
             if let image = UIImage(data: data) {
             DispatchQueue.main.async {
             self.imageCache.setObject(image, forKey: NSImageURL)
             }
             }
             case .failure(let error):
             print("failure downloading image", error)
             }
             }
             }
             }*/
        }
        
        if message.imageURL != "" {
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "pictureMessageCell", for: indexPath) as! PictureMessageTableViewCell
            
            self.photoCount += 1
            
            cell.messageImageView.image = nil
            
            cell.groupPosition = self.checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
            
            cell.isGroupMessage = false
            
            if message.messageSender == userFullName {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.imageURL = message.imageURL!
            
            let imageURL = message.imageURL!
            
            let NSImageURL = message.imageURL! as NSString
            
            /*if let cachedImage = self.imageCache.object(forKey: NSImageURL as NSString) as? UIImage {
             cell.messageImageView.image = cachedImage
             let imageHeight = CGFloat(cachedImage.size.height/cachedImage.size.width * 300)
             print("Cached", imageHeight)
             cell.imageHeight = imageHeight
             if !self.chatImagesArray.contains(imageURL) {
             self.currentChatImageDictionary.removeValue(forKey: imageURL)
             }
             } else*/ if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") {
                 if let storedImageData = chatImageDictionary[imageURL] as? Data {
                     let image = UIImage(data: storedImageData)!
                     print("Already Contained DM Chat Photo")
                     cell.messageImageView.image = image
                     let imageHeight = CGFloat(message.imageHeight/message.imageWidth * 300)
                     cell.imageHeight = imageHeight
                     self.imageCache.setObject(image, forKey: NSImageURL as NSString)
                     if !self.chatImagesArray.contains(imageURL) {
                         self.currentChatImageDictionary.removeValue(forKey: imageURL)
                     }
                 } else {
                     let imageHeight = CGFloat(message.imageHeight/message.imageWidth * 300)
                     cell.imageHeight = imageHeight
                     Amplify.Storage.downloadData(key: imageURL) { result in
                         switch result {
                         case .success(let data):
                             print("Success downloading image", data)
                             if let image = UIImage(data: data) {
                                 DispatchQueue.main.async {
                                     cell.messageImageView.image = image
                                     self.imageCache.setObject(image, forKey: NSImageURL as NSString)
                                     if self.chatImagesArray.contains(imageURL) {
                                         self.currentChatImageDictionary[imageURL] = data
                                         print("currentImageDictionary")
                                         print(self.currentChatImageDictionary.count)
                                         print(self.currentChatImageDictionary.keys)
                                         self.defaults.setValue(self.currentChatImageDictionary, forKey: "\(self.documentID) photos")
                                     }
                                 }
                             }
                         case .failure(let error):
                             print("failure downloading image", error)
                         }
                     }
                 }
             }
            
            /*else {
             let imageHeight = CGFloat(message.imageHeight/message.imageWidth * 300)
             cell.imageHeight = imageHeight
             Amplify.Storage.downloadData(key: imageURL) { result in
             switch result {
             case .success(let data):
             print("Success downloading image", data)
             if let image = UIImage(data: data) {
             //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
             DispatchQueue.main.async {
             cell.messageImageView.image = image
             self.imageCache.setObject(image, forKey: NSImageURL as NSString)
             /*cell.messageImageView.image = image
              self.imageCache.setObject(image, forKey: NSImageURL as NSString)
              //self.photoDictionary[imageURL] = image*/
             }
             }
             case .failure(let error):
             print("failure downloading image", error)
             }
             }
             }*/
            
            cell.emailLabel.text = message.messageSenderNickName
            
            cell.isGroupMessage = false
            
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            return cell
            
        } else {
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! BubbleMessageBodyCell
            
            var reversedKeyArray: [String] = []
            
            for value in self.keyArray.reversed() {
                reversedKeyArray.append(value)
            }
            
            let key = reversedKeyArray[indexPath.section]
            
            let sortedMessages = self.messages[key]!.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let message = sortedMessages[indexPath.row]
            
            if let messageBody = message.messageBody {
                
                cell.messageBody.text = messageBody
                cell.documentID = self.documentID
                cell.timeStamp = message.timeStamp
                
                let decimalRange = messageBody.rangeOfCharacter(from: CharacterSet.decimalDigits)
                
                let messageBodyHasNumbers = (decimalRange != nil)
                
                if (messageBody.contains("Venmo") || messageBody.contains("venmo"))  && messageBodyHasNumbers {
                    
                    if message.messageSender != userFullName {
                        cell.isVenmoRequest = true
                        cell.venmoName = self.otherUserVenmoName
                        
                        let numString = messageBody.numArray.joined(separator: " ")
                        let numArray = numString.split(separator: " ").map(String.init)
                        
                        if numArray.count == 1 {
                            cell.venmoAmount = numArray.first!
                        }
                        
                        if message.messageSender == userFullName {
                            cell.isIncoming = false
                        } else {
                            cell.isIncoming = true
                        }
                        
                        cell.bubbleView.layer.borderColor = UIColor(named: "BrightBlue")?.cgColor
                        cell.bubbleView.backgroundColor = UIColor(named: "BrightBlue")?.withAlphaComponent(0.25)
                        
                    } else {
                        cell.isVenmoRequest = false
                        
                        if message.messageSender == userFullName {
                            cell.isIncoming = false
                        } else {
                            cell.isIncoming = true
                        }
                        
                        cell.bubbleView.layer.borderColor = UIColor(named: "BrightBlue")?.cgColor
                        cell.bubbleView.backgroundColor = UIColor(named: "BrightBlue")?.withAlphaComponent(0.25)
                    }
                } else {
                    cell.isVenmoRequest = false
                    
                    if message.messageSender == userFullName {
                        cell.isIncoming = false
                    } else {
                        cell.isIncoming = true
                    }
                }
            }
            cell.groupPosition = self.checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
            cell.messageBody.text = message.messageBody
            cell.messageTextView.text = message.messageBody
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keyArray.count
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 50
     }*/
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var reversedKeyArray: [String] = []
        
        for value in self.keyArray.reversed() {
            reversedKeyArray.append(value)
        }
        
        let specificSection = reversedKeyArray[section]
        
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
            headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            let containerView = UIView()
            containerView.addSubview(headerLabel)
            containerView.backgroundColor = UIColor(named: "WarmBlack") //UIColor.init(named: K.BrandColors.backgroundBlack)
            
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
    
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
     headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
     
     let containerView = UIView()
     containerView.addSubview(headerLabel)
     containerView.backgroundColor = .black //UIColor.init(named: K.BrandColors.backgroundBlack)
     
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
     }*/
    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     
     let specificSection = self.keyArray[section]
     
     if let firstMessageInSection = self.messages[specificSection]?.first {
     dateFormatter.dateFormat = "MM/dd/yyyy"
     let date = Date(timeIntervalSince1970: firstMessageInSection.timeStamp)
     return dateFormatter.string(from: date)
     }
     
     return "Fuck it failed"
     }*/
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     
     let regularMessageCell = cell as! RegularMessageBody
     
     regularMessageCell.messageBodyView.layer.cornerRadius = regularMessageCell.messageBody.bounds.height/4
     regularMessageCell.messageBodyView.layer.borderWidth = 2
     regularMessageCell.messageBodyView.layer.backgroundColor = UIColor.clear.cgColor
     
     }*/
}








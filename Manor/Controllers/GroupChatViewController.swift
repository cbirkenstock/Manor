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
import Amplify
import AmplifyPlugins

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

class GroupChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PHPickerViewControllerDelegate, UITextFieldDelegate {
    
    
    
    
    
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
    let eventChatsByUserRef =
        Database.database().reference().child("EventChatsByUser")
    let eventChatMessagesRef = Database.database().reference().child("EventChatMessages")
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
    let photoManager = PhotoManagerViewController()
    let eventButton = UIButton()
    let plusImageView = UIImageView()
    let titleField = UITextField()
    let descriptionTextField = UITextView()
    let backgroundView = UIView()
    var a: CGFloat = 0
    let datePicker = UIDatePicker()
    let eventSendButton = UIButton()
    var eventCancelButton = UIButton()
    let titleUnderline = UIView()
    var textFieldConstraints: [NSLayoutConstraint]!
    var titleUnderlineConstraints: [NSLayoutConstraint]!
    var datePickerConstraints: [NSLayoutConstraint]!
    var descriptionTextFieldConstraints: [NSLayoutConstraint]!
    var eventSendButtonConstraints: [NSLayoutConstraint]!
    var eventCancelButtonConstraints: [NSLayoutConstraint]!
    var eventCapConstraints: [NSLayoutConstraint]!
    var isCallingEvent: Bool = false
    var photoDictionary: [String: UIImage] = [:]
    let firebaseManager = FirebaseManagerViewController()
    var isEventChat: Bool! = false
    var eventCap: UITextField = UITextField()
    var eventDescription: String?
    var eventDate: String?
    var eventTime: String?
    var userChatImage: String?
    var photoCount: Int = 0
    var chatImagesArray: [String] = []
    var currentChatImageDictionary: [String:Data] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") as? [String: Data] {
            self.currentChatImageDictionary = chatImageDictionary
        } else {
            self.defaults.setValue([:], forKey: "\(self.documentID) photos")
        }
        
        if self.isEventChat {
            print(self.documentID)
            eventChatMessagesRef.child(documentID).observe(DataEventType.value) { DataSnapshot in
                if let postDict = DataSnapshot.value as? [String: Any] {
                    self.eventDescription = "Description: \(postDict["eventDescription"] as? String ?? "")"
                    self.eventDate = "Date: \(postDict["eventDate"] as? String ?? "")"
                    self.eventTime = "Time: \(postDict["eventTime"] as? String ?? "")"
                    self.chatTableView.reloadData()
                }
            }
        }
        
        chatTableView.keyboardDismissMode = .interactive
        
        chatTextBar.attributedPlaceholder = NSAttributedString(string: "Chat...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        
        
        
        
        self.initialBottomConstraint = self.bottomConstraint.constant
        
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
                print("TRUEE")
                let firstName = value["firstName"] as? String ?? ""
                let lastName = value["lastName"] as? String ?? ""
                self.userFullName = "\(firstName) \(lastName)"
                self.userVenmoName = value["venmoName"] as? String ?? ""
                self.chatTableView.reloadData()
                self.userChatImage = value["profileImageUrl"] as? String ?? ""
                
                /*if let navigationController = self.navigationController, let _ = self.user {
                 let userEntry  = [self.userFullName, self.user.email!]
                 if !self.groupMembers.contains(userEntry) {
                 var navigationArray = navigationController.viewControllers
                 navigationArray.remove(at: navigationArray.count - 1)
                 }
                 }*/
            } else {
                print("No Value")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        if self.isEventChat {
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
        } else {
            eventChatsByUserRef.child(commaEmail).child("Chats").child(self.documentID).child("nickName").observe(DataEventType.value, with: { (snapshot) in
                // Get user value
                if let userNickName = snapshot.value as? String {
                    self.userNickName = userNickName
                } else {
                    print("No Value")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        self.keyboardIsShowing = false
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(named: "WarmBlack")
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        
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
        
        chatTableView.register(EventTableViewCell.self, forCellReuseIdentifier: "eventMessageCell")
        
        chatTableView.register(EventInfoTableViewCell.self, forCellReuseIdentifier: "eventInfoCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textBarView.layer.cornerRadius = chatTextBar.bounds.height/2
        textBarView.layer.backgroundColor = UIColor.clear.cgColor
        textBarView.layer.borderWidth = 3
        textBarView.layer.borderColor =
            UIColor.white.cgColor//UIColor(named: "BrandPurpleColor")?.cgColor
        textBarView.backgroundColor = .black
        
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if !isEventChat {
            setUpEventsButton()
            setUpEventOptions()
        }
        
        self.loadMessages()
        self.setUpPushMessagesTable()
        self.loadMessages()
        
    }
    
    func setUpEventsButton() {
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(eventButton, aboveSubview: chatTableView)
        eventButton.backgroundColor = UIColor(named: K.BrandColors.purple)
        eventButton.layer.cornerRadius = 50/2
        eventButton.addTarget(self, action: #selector(createEventButtonPressed), for: .touchUpInside)
        
        let eventButtonContainerConstraints = [
            eventButton.heightAnchor.constraint(equalToConstant: 50),
            eventButton.widthAnchor.constraint(equalToConstant: 50),
            eventButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -1),
            eventButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 1)
        ]
        
        NSLayoutConstraint.activate(eventButtonContainerConstraints)
        
        self.view.addSubview(plusImageView)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.image = UIImage(systemName: "calendar")
        plusImageView.tintColor = .white
        
        let plusImageViewConstraints = [
            plusImageView.topAnchor.constraint(equalTo: eventButton.topAnchor, constant: 7),
            plusImageView.bottomAnchor.constraint(equalTo: eventButton.bottomAnchor, constant: -7),
            plusImageView.leadingAnchor.constraint(equalTo: eventButton.leadingAnchor, constant: 7),
            plusImageView.trailingAnchor.constraint(equalTo: eventButton.trailingAnchor, constant: -7)
        ]
        
        NSLayoutConstraint.activate(plusImageViewConstraints)
        
    }
    
    @objc func createEventButtonPressed() {
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.titleField)
        self.view.addSubview(self.titleUnderline)
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.descriptionTextField)
        self.view.addSubview(self.eventSendButton)
        self.view.addSubview(self.eventCancelButton)
        self.view.addSubview(self.eventCap)
        
        self.isCallingEvent = true
        self.titleField.becomeFirstResponder()
    }
    
    func setUpEventOptions() {
        self.view.insertSubview(backgroundView, aboveSubview: plusImageView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor(named: K.BrandColors.backgroundBlack)
        backgroundView.layer.cornerRadius = 20
        
        self.view.addSubview(titleField)
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.backgroundColor = .clear
        titleField.textColor = .clear
        titleField.font = UIFont.systemFont(ofSize: 33)
        titleField.text = "Title..."
        titleField.tintColor = .white
        titleField.delegate = self
        
        self.textFieldConstraints = [
            titleField.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
            titleField.heightAnchor.constraint(equalToConstant: 40),
            titleField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            titleField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10)
        ]
        
        self.view.addSubview(titleUnderline)
        titleUnderline.translatesAutoresizingMaskIntoConstraints = false
        titleUnderline.backgroundColor = UIColor(named: K.BrandColors.purple)
        
        
        self.titleUnderlineConstraints = [
            titleUnderline.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 1),
            titleUnderline.heightAnchor.constraint(equalToConstant: 2),
            titleUnderline.leadingAnchor.constraint(equalTo: titleField.leadingAnchor, constant: 0),
            titleUnderline.trailingAnchor.constraint(equalTo: titleField.trailingAnchor, constant: 0)
            
        ]
        
        self.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.tintColor = .white //UIColor(named: K.BrandColors.purple)
        datePicker.isHidden = true
        
        self.datePickerConstraints = [
            datePicker.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 18)
        ]
        
        self.view.addSubview(eventCap)
        eventCap.isHidden = true
        eventCap.translatesAutoresizingMaskIntoConstraints = false
        eventCap.delegate = self
        eventCap.backgroundColor = UIColor(named: "Gray")
        eventCap.layer.cornerRadius = 5
        eventCap.textColor = .white
        eventCap.text = "No Limit"
        eventCap.textAlignment = .center
        
        self.eventCapConstraints = [
            eventCap.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: 20),
            eventCap.heightAnchor.constraint(equalToConstant: datePicker.frame.height),
            eventCap.leadingAnchor.constraint(equalTo: datePicker.trailingAnchor, constant: 5),
            eventCap.widthAnchor.constraint(equalToConstant: 80)
        ]
        
        self.view.addSubview(descriptionTextField)
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.delegate = self
        descriptionTextField.backgroundColor = UIColor(named: K.BrandColors.purple)
        descriptionTextField.textColor = .systemGray
        descriptionTextField.font = UIFont.systemFont(ofSize: 25)
        descriptionTextField.text = "description..."
        descriptionTextField.layer.cornerRadius = 10
        descriptionTextField.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10)
        descriptionTextField.tintColor = .white
        
        
        self.descriptionTextFieldConstraints = [
            descriptionTextField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            descriptionTextField.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -65),
            descriptionTextField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            descriptionTextField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10)
        ]
        
        self.view.addSubview(self.eventSendButton)
        self.eventSendButton.translatesAutoresizingMaskIntoConstraints = false
        self.eventSendButton.backgroundColor = .clear
        self.eventSendButton.layer.cornerRadius = 8
        self.eventSendButton.setTitle("Create", for: .normal)
        self.eventSendButton.setTitleColor(.clear, for: .normal)
        self.eventSendButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        self.eventSendButton.addTarget(self, action: #selector(sendEventButtonPressed), for: .touchUpInside)
        
        
        self.eventSendButtonConstraints = [
            eventSendButton.topAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 10),
            eventSendButton.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor, constant: -5),
            eventSendButton.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -10),
            eventSendButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 100)/2 - 15))
        ]
        
        self.view.addSubview(self.eventCancelButton)
        self.eventCancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.eventCancelButton.backgroundColor = .clear
        self.eventCancelButton.layer.cornerRadius = 8
        self.eventCancelButton.setTitle("Cancel", for: .normal)
        self.eventCancelButton.setTitleColor(.clear, for: .normal)
        self.eventCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        self.eventCancelButton.addTarget(self, action: #selector(cancelEventbuttonPressed), for: .touchUpInside)
        
        
        self.eventCancelButtonConstraints = [
            eventCancelButton.topAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 10),
            eventCancelButton.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor, constant: -5),
            eventCancelButton.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 10),
            eventCancelButton.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 100)/2 - 15))
        ]
    }
    
    @objc func sendEventButtonPressed() {
        if self.titleField.text != "" && self.descriptionTextField.text != "" {
            self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            self.dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
            self.dateFormatter.amSymbol = "AM"
            self.dateFormatter.pmSymbol = "PM"
            
            let eventTitle = self.titleField.text
            let eventDescription = self.descriptionTextField.text
            let eventCapText = self.eventCap.text
            
            let eventTimeStampArray = self.dateFormatter.string(from: self.datePicker.date).split(separator: " ")
            let eventDate = String(eventTimeStampArray[0])
            let eventTime = String("\(eventTimeStampArray[1]) \(eventTimeStampArray[2])")
            
            let timeStamp = Date().timeIntervalSince1970
            let stringTimestamp = "\(timeStamp)"
            let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
            
            let eventDocumentID: String = "\(Int.random(in: 1...10000000000000))"
            
            let alert = UIAlertController(title: "Create Event?", message: "Title: \(self.titleField.text ?? "Title...")\n Date: \(eventDate)\n Time: \(eventTime)\n Description: \(self.descriptionTextField.text ?? "description")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { UIAlertAction in
                self.backgroundView.removeFromSuperview()
                self.titleField.removeFromSuperview()
                self.titleUnderline.removeFromSuperview()
                self.datePicker.removeFromSuperview()
                self.descriptionTextField.removeFromSuperview()
                self.eventSendButton.removeFromSuperview()
                self.eventCancelButton.removeFromSuperview()
                self.eventCap.removeFromSuperview()
                
                self.chatTableView.isHidden = false
                self.eventButton.isHidden = false
                self.plusImageView.isHidden = false
                self.isCallingEvent = false
                
                
                
                self.eventChatMessagesRef.child(eventDocumentID).setValue([
                    "title": eventTitle ?? "",
                    "messageCreator": self.user!.email!,
                    "timeStamp": commaTimestamp,
                    "Members": [[self.userFullName, self.user!.email!]],
                    "lastMessage": "",
                    "documentID": eventDocumentID,
                    "eventCap": eventCapText ?? "no limit",
                    "eventDescription": eventDescription,
                    "eventDate": eventDate,
                    "eventTime": eventTime,
                ])
                
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/title").setValue(eventTitle)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/documentID").setValue(eventDocumentID)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/lastMessage").setValue("")
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/profileImageUrl").setValue("default")
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/notificationsEnabled").setValue(true)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/timeStamp").setValue(commaTimestamp)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/readNotification").setValue(false)
                
                self.titleField.text = ""
                self.descriptionTextField.text = ""
                
                self.groupChatMessagesRef.child("\(self.documentID)/lastMessage").setValue("\(self.userFullName) sent an event")
                self.groupChatMessagesRef.child("\(self.documentID)/senderEmail").setValue(self.user.email!)
                self.groupChatMessagesRef.child("\(self.documentID)/timeStamp").setValue(commaTimestamp)
                
                self.groupChatMessagesRef.child(self.documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                    "messageSender": self.userFullName,
                    "messageSenderNickName": self.userNickName ?? self.userFullName,
                    "eventTitle": eventTitle,
                    "eventDescription": eventDescription,
                    "eventDate": eventDate,
                    "eventTime": eventTime,
                    "timeStamp": commaTimestamp,
                    "likes": "0",
                    "documentID": eventDocumentID,
                    "eventCap": eventCapText,
                    "currentNumber": "0"
                ])
                
                for member in self.groupMembers {
                    let email = member[1]
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/title").setValue(self.groupChatTitle)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/documentID").setValue(self.documentID)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/profileImageUrl").setValue(self.groupChatImageUrl)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/notificationsEnabled").setValue(true)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/lastMessage").setValue("\(self.userFullName) sent an event")
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/timeStamp").setValue(commaTimestamp)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/readNotification").setValue(false)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
                self.dismiss(animated: true)
            }))
            
            self.present(alert, animated: true)
        } else {
            self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            self.dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
            self.dateFormatter.amSymbol = "AM"
            self.dateFormatter.pmSymbol = "PM"
            
            let eventTitle = self.titleField.text
            let eventDescription = self.descriptionTextField.text
            let eventCapText = self.eventCap.text
            
            let eventTimeStampArray = self.dateFormatter.string(from: self.datePicker.date).split(separator: " ")
            let eventDate = String(eventTimeStampArray[0])
            let eventTime = String("\(eventTimeStampArray[1]) \(eventTimeStampArray[2])")
            
            let timeStamp = Date().timeIntervalSince1970
            let stringTimestamp = "\(timeStamp)"
            let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
            
            let eventDocumentID: String = "\(Int.random(in: 1...10000000000000))"
            
            let alert = UIAlertController(title: "Missing Information", message: "Please confirm you'd like to send event with the information you have.\n Title: \(self.titleField.text ?? "Title...")\n Date: \(eventDate)\n Time: \(eventTime)\n Description: \(self.descriptionTextField.text ?? "description")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { UIAlertAction in
                self.backgroundView.removeFromSuperview()
                self.titleField.removeFromSuperview()
                self.titleUnderline.removeFromSuperview()
                self.datePicker.removeFromSuperview()
                self.descriptionTextField.removeFromSuperview()
                self.eventSendButton.removeFromSuperview()
                self.eventCancelButton.removeFromSuperview()
                self.eventCap.removeFromSuperview()
                
                self.chatTableView.isHidden = false
                self.eventButton.isHidden = false
                self.plusImageView.isHidden = false
                self.isCallingEvent = false
                
                
                
                self.eventChatMessagesRef.child(eventDocumentID).setValue([
                    "title": eventTitle ?? "",
                    "messageCreator": self.user!.email!,
                    "timeStamp": commaTimestamp,
                    "Members": [[self.userFullName, self.user!.email!]],
                    "lastMessage": "",
                    "documentID": eventDocumentID,
                    "eventCap": eventCapText ?? "no limit"
                ])
                
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/title").setValue(eventTitle)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/documentID").setValue(eventDocumentID)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/lastMessage").setValue("")
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/profileImageUrl").setValue("default")
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/notificationsEnabled").setValue(true)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/timeStamp").setValue(commaTimestamp)
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(eventDocumentID)/readNotification").setValue(false)
                
                self.titleField.text = ""
                self.descriptionTextField.text = ""
                
                self.groupChatMessagesRef.child("\(self.documentID)/lastMessage").setValue("\(self.userFullName) sent an event")
                self.groupChatMessagesRef.child("\(self.documentID)/senderEmail").setValue(self.user.email!)
                self.groupChatMessagesRef.child("\(self.documentID)/timeStamp").setValue(commaTimestamp)
                
                self.groupChatMessagesRef.child(self.documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                    "messageSender": self.userFullName,
                    "messageSenderNickName": self.userNickName ?? self.userFullName,
                    "eventTitle": eventTitle,
                    "eventDescription": eventDescription,
                    "eventDate": eventDate,
                    "eventTime": eventTime,
                    "timeStamp": commaTimestamp,
                    "likes": "0",
                    "documentID": eventDocumentID,
                    "eventCap": eventCapText,
                    "currentNumber": "0"
                ])
                
                for member in self.groupMembers {
                    let email = member[1]
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/title").setValue(self.groupChatTitle)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/documentID").setValue(self.documentID)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/profileImageUrl").setValue(self.groupChatImageUrl)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/notificationsEnabled").setValue(true)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/lastMessage").setValue("\(self.userFullName) sent an event")
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/timeStamp").setValue(commaTimestamp)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/readNotification").setValue(false)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
                self.dismiss(animated: true)
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc func cancelEventbuttonPressed() {
        self.backgroundView.removeFromSuperview()
        self.titleField.removeFromSuperview()
        self.titleUnderline.removeFromSuperview()
        self.datePicker.removeFromSuperview()
        self.descriptionTextField.removeFromSuperview()
        self.eventSendButton.removeFromSuperview()
        self.eventCancelButton.removeFromSuperview()
        self.eventCap.removeFromSuperview()
        
        self.chatTableView.isHidden = false
        self.eventButton.isHidden = false
        self.plusImageView.isHidden = false
        self.isCallingEvent = false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "description..." {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.titleField {
            textField.text = ""
            self.titleField.textColor = .white
        } else {
            textField.text = ""
        }
    }
    
    private func setUpTextView() {
        
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
        //        let window = UIApplication.shared.keyWindow
        //        self.initialBottomConstraint = window?.safeAreaInsets.bottom ?? 0.0
        //print(self.chatTextBar.frame.origin.y)
        //pushMessagesTableView.isScrollEnabled = false
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideNavigationBar"), object: nil)
        
        /*self.firebaseManager.downloadChatPhotos(documentID: self.documentID) { photoDictionary in
         DispatchQueue.main.async {
         print("we finished")
         self.photoDictionary = photoDictionary
         
         }
         }*/
        
        self.pushMessagesTableView.backgroundColor = .clear
        
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //navigationController?.navigationBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        /*self.keyboardIsShowing = true
         self.pushMessageButton.image = UIImage(systemName: "pin")
         self.pushMessageButton.tintColor = UIColor(named: K.BrandColors.red)*/
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        
        let spaceLeft = (self.view.bounds.height - keyboardFrame) - backgroundView.frame.height
        
        bottomConstraint.constant = keyboardFrame + 1
        
        self.textBarRightConstraint.constant = 120
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        
        if self.isCallingEvent {
            let yValue = self.view.bounds.origin.y + (spaceLeft/6)
            
            let backgroundViewConstraints = [
                backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: yValue),
                backgroundView.leadingAnchor.constraint(equalTo: self.chatTableView.leadingAnchor, constant: 40),
                backgroundView.trailingAnchor.constraint(equalTo: self.chatTableView.trailingAnchor, constant: -40),
                backgroundView.heightAnchor.constraint(equalToConstant: 275)
            ]
            
            /*let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
             let blurEffectView = UIVisualEffectView(effect: blurEffect)
             blurEffectView.frame = UIScreen.main.bounds//chatTableView.bounds
             blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
             chatTableView.addSubview(blurEffectView)*/
            
            self.chatTableView.isHidden = true
            self.eventButton.isHidden = true
            self.plusImageView.isHidden = true
            NSLayoutConstraint.activate(backgroundViewConstraints)
            NSLayoutConstraint.activate(self.textFieldConstraints)
            self.titleField.textColor = .systemGray
            NSLayoutConstraint.activate(self.titleUnderlineConstraints)
            self.datePicker.isHidden = false
            NSLayoutConstraint.activate(self.datePickerConstraints)
            NSLayoutConstraint.activate(self.descriptionTextFieldConstraints)
            self.eventSendButton.backgroundColor = .systemGreen
            self.eventSendButton.setTitleColor(.white, for: .normal)
            NSLayoutConstraint.activate(self.eventSendButtonConstraints)
            self.eventCancelButton.backgroundColor = .systemRed
            self.eventCancelButton.setTitleColor(.white, for: .normal)
            NSLayoutConstraint.activate(eventCancelButtonConstraints)
            eventCap.isHidden = false
            NSLayoutConstraint.activate(eventCapConstraints)
            
            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        self.keyboardIsShowing = false
        
        self.pushMessageButton.image = UIImage(systemName: "ellipsis")
        self.pushMessageButton.tintColor = UIColor(named: K.BrandColors.purple)
        
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        print("initialBottomConstraint")
        print(initialBottomConstraint)
        
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
        self.photoManager.documentID = self.documentID
        self.photoManager.groupMembers = self.groupMembers
        self.photoManager.groupChatTitle = self.groupChatTitle
        self.photoManager.userFullName = self.userFullName
        self.photoManager.setUpCameraPicker(viewController: self, desiredPicker: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let isEventChat = self.isEventChat!
        
        photoManager.processPickerResultOld(imagePicker: picker, info: info, isTextMessage: true, isGroupMessage: true, isEventChat: isEventChat)
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let isEventChat = self.isEventChat!
        
        photoManager.processPickerResultsPHP(imagePicker: picker, results: results, isGroupMessage: true, isEventChat: isEventChat)
    }
    
    @IBAction func pushButtonPressed(_ sender: UIBarButtonItem) {
        
        if let messageBody = chatTextBar.text, self.keyboardIsShowing == true {
            
            let pushMessageUID = String(Int.random(in: 1...10000000000000))
            
            let timestamp = (Date().timeIntervalSince1970)
            let timestampString = ("\(timestamp)")
            let commaTimestamp =  timestampString.replacingOccurrences(of: ".", with: ",")
            
            self.chatTextBar.text = ""
            
            if isEventChat {
                
                self.eventChatMessagesRef.child(documentID).child("pushMessages").child(String(pushMessageUID)).setValue([
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
                
                self.eventChatMessagesRef.child("\(self.documentID)/timeStamp").setValue(commaTimestamp)
                
                for email in groupMembers[1] {
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.eventChatsByUserRef.child(commaEmail).child("Chats").child(documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { snapshot in
                        var unreadPushMessages = snapshot.value as? [String] ?? []
                        unreadPushMessages.append(pushMessageUID)
                        
                        if email == self.user.email {
                            self.unreadPushMessages = unreadPushMessages
                        }
                        
                        self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(self.documentID)/title").setValue(self.groupChatTitle)
                        self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(self.documentID)/documentID").setValue(self.documentID)
                        self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(self.documentID)/lastMessage").setValue(messageBody)
                        self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(self.documentID)/timeStamp").setValue(commaTimestamp)
                        self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(self.documentID)/unreadPushMessages").setValue(unreadPushMessages)
                    }
                }
            } else {
                
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
                
                self.groupChatMessagesRef.child("\(self.documentID)/timeStamp").setValue(commaTimestamp)
                
                for email in groupMembers[1] {
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.groupChatByUsersRef.child(commaEmail).child("Chats").child(documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { snapshot in
                        var unreadPushMessages = snapshot.value as? [String] ?? []
                        unreadPushMessages.append(pushMessageUID)
                        
                        if email == self.user.email {
                            self.unreadPushMessages = unreadPushMessages
                        }
                        
                        self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/title").setValue(self.groupChatTitle)
                        self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/documentID").setValue(self.documentID)
                        self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/lastMessage").setValue(messageBody)
                        self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/timeStamp").setValue(commaTimestamp)
                        self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID)/unreadPushMessages").setValue(unreadPushMessages)
                    }
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
            vc.isEventChat = self.isEventChat
        }
    }
    
    @objc func readButtonPressed(_ sender: UIButton) {
        let pushMessageUID = self.unreadPushMessages[sender.tag]
        self.unreadPushMessages = self.unreadPushMessages.filter { $0 != pushMessageUID }
        self.pushMessagesTableView.reloadData()
        let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
        
        if self.isEventChat {
            self.eventChatsByUserRef.child(commaEmail).child("Chats").child(self.documentID).child("unreadPushMessages").setValue(self.unreadPushMessages) { err, DatabaseReference in
                if let err = err {
                    print(err)
                } else {
                    if self.unreadPushMessages.count == 0 {
                        self.pushMessages = []
                        self.pushMessagesTableView.reloadData()
                    } else {
                        self.loadMessages()
                    }
                }
            }
        } else {
            self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID).child("unreadPushMessages").setValue(self.unreadPushMessages) { err, DatabaseReference in
                if let err = err {
                    print(err)
                } else {
                    if self.unreadPushMessages.count == 0 {
                        self.pushMessages = []
                        self.pushMessagesTableView.reloadData()
                    } else {
                        self.loadMessages()
                    }
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
            
            if isEventChat {
                self.eventChatMessagesRef.child("\(documentID)/lastMessage").setValue(messageBody)
                self.eventChatMessagesRef.child("\(documentID)/senderEmail").setValue(self.user.email!)
                self.eventChatMessagesRef.child("\(documentID)/timeStamp").setValue(commaTimestamp)
                
                let decimalRange = messageBody.rangeOfCharacter(from: CharacterSet.decimalDigits)
                
                let messageBodyHasNumbers = (decimalRange != nil)
                
                if messageBody.contains("Venmo") && messageBodyHasNumbers {
                    self.eventChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                        "messageSender": userFullName,
                        "messageSenderNickName": self.userNickName ?? self.userFullName,
                        "messageSenderChatImage": self.userChatImage ?? "default",
                        "messageBody": messageBody,
                        "timeStamp": commaTimestamp,
                        "venmoName": self.userVenmoName
                    ])
                } else {
                    self.eventChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                        "messageSender": userFullName,
                        "messageSenderNickName": self.userNickName ?? self.userFullName,
                        "messageSenderChatImage": self.userChatImage ?? "default",
                        "messageBody": messageBody,
                        "timeStamp": commaTimestamp,
                        "likes": "0"
                    ])
                }
                
                for member in groupMembers {
                    let email = member[1]
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/title").setValue(groupChatTitle)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/documentID").setValue(documentID)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/profileImageUrl").setValue(self.groupChatImageUrl)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/notificationsEnabled").setValue(true)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/lastMessage").setValue(messageBody)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/timeStamp").setValue(commaTimestamp)
                    self.eventChatsByUserRef.child("\(commaEmail)/Chats/\(documentID)/readNotification").setValue(false)
                }
            } else {
                self.groupChatMessagesRef.child("\(documentID)/lastMessage").setValue(messageBody)
                self.groupChatMessagesRef.child("\(documentID)/senderEmail").setValue(self.user.email!)
                self.groupChatMessagesRef.child("\(documentID)/timeStamp").setValue(commaTimestamp)
                
                let decimalRange = messageBody.rangeOfCharacter(from: CharacterSet.decimalDigits)
                
                let messageBodyHasNumbers = (decimalRange != nil)
                
                if messageBody.contains("Venmo") && messageBodyHasNumbers {
                    self.groupChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                        "messageSender": userFullName,
                        "messageSenderNickName": self.userNickName ?? self.userFullName,
                        "messageSenderChatImage": self.userChatImage ?? "default",
                        "messageBody": messageBody,
                        "timeStamp": commaTimestamp,
                        "venmoName": self.userVenmoName
                    ])
                } else {
                    self.groupChatMessagesRef.child(documentID).child("Messages").child("Message,\(commaTimestamp)").setValue([
                        "messageSender": userFullName,
                        "messageSenderNickName": self.userNickName ?? self.userFullName,
                        "messageSenderChatImage": self.userChatImage ?? "default",
                        "messageBody": messageBody,
                        "timeStamp": commaTimestamp,
                        "likes": "0"
                    ])
                }
                
                for member in groupMembers {
                    let email = member[1]
                    let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                    
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/title").setValue(groupChatTitle)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/documentID").setValue(documentID)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/profileImageUrl").setValue(self.groupChatImageUrl)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/notificationsEnabled").setValue(true)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/lastMessage").setValue(messageBody)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/timeStamp").setValue(commaTimestamp)
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(documentID)/readNotification").setValue(false)
                }
            }
        }
    }
    
    func loadMessages() {
        let userBadgeCountRef = usersRef.child(self.commaEmail).child("badgeCount")
        
        let MessagesRef: DatabaseReference
        
        if isEventChat {
            let conversationBadgeCountRef = eventChatsByUserRef.child(self.commaEmail).child("Chats").child(self.documentID).child("badgeCount")
            
            conversationBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
                self.eventChatsByUserRef.child("\(self.commaEmail)/Chats/\(self.documentID)/readNotification").setValue(true)
            })
            
            MessagesRef = eventChatMessagesRef.child(documentID).child("Messages")
        } else {
            
            let conversationBadgeCountRef = groupChatByUsersRef.child(self.commaEmail).child("Chats").child(self.documentID).child("badgeCount")
            
            conversationBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
                self.groupChatByUsersRef.child("\(self.commaEmail)/Chats/\(self.documentID)/readNotification").setValue(true)
            })
            
            MessagesRef = groupChatMessagesRef.child(documentID).child("Messages")
            
        }
        
        MessagesRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.messages = [:]
            self.keyArray = []
            for value in postDict.values {
                if let messageSender = value.object(forKey: "messageSender")! as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    let messageSenderNickName = value.object(forKey: "messageSenderNickName") as? String ?? messageSender
                    let messageSenderChatImage = value.object(forKey: "messageSenderChatImage") as? String ?? "default"
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
                        
                        var message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: nil, messageSenderNickName: messageSenderNickName, messageSenderChatImage: messageSenderChatImage)
                        
                        if let venmoName = value.object(forKey: "venmoName") as? String {
                            message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: nil, venmoName: venmoName, messageSenderNickName: messageSenderNickName, messageSenderChatImage: messageSenderChatImage)
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
                    } else if let imageURL = value.object(forKey: "imageURL") as? String {
                        
                        let imageWidth = value.object(forKey: "imageWidth") as? Double ?? 300
                        let imageHeight = value.object(forKey: "imageHeight") as? Double ?? 400
                        
                        self.totalMessages += 1
                        
                        let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                        
                        let message = Message(messageSender: messageSender, messageBody: nil, timeStamp: timeStamp, pushMessageUID: nil, imageURL: imageURL, messageSenderNickName: messageSenderNickName, imageWidth: imageWidth, imageHeight: imageHeight)
                        
                        //let NSImageUrl = message.imageURL! as NSString
                        
                        //self.cacheImage(imageURL: imageURL)
                        
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
                        
                        if self.photoCount < 30 {
                            self.chatImagesArray.append(imageURL)
                            self.photoCount += 1
                        }
                        self.chatTableView.reloadData()
                    } else if let eventTitle = value.object(forKey: "eventTitle") as? String, let eventDescription =  value.object(forKey: "eventDescription") as? String, let eventDate = value.object(forKey: "eventDate") as? String, let eventTime = value.object(forKey: "eventTime") as? String, let eventDocumentID = value.object(forKey: "documentID") as? String {
                        
                        let eventCap = value.object(forKey: "eventCap") as? String ?? "No Limit"
                        let currentNumber = value.object(forKey: "currentNumber") as? String ?? "0"
                        
                        self.totalMessages += 1
                        
                        let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                        
                        self.dateFormatter.dateFormat = "MM/dd/yyyy"
                        let messageDate = self.dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
                        
                        let event = Event(title: eventTitle, description: eventDescription, date: eventDate, time: eventTime, documentID: eventDocumentID, eventCap: eventCap, currentNumber: currentNumber)
                        
                        let message = Message(messageSender: messageSender, messageBody: nil, timeStamp: timeStamp, pushMessageUID: nil, messageSenderNickName: messageSenderNickName, event: event)
                        
                        
                        
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
                        
                    }
                }
            }
        })
        
        userBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
            let postIntAsString = snapshot.value! as? String ?? "0"
            let postInt = Int(postIntAsString)
            UIApplication.shared.applicationIconBadgeNumber = postInt!
        })
        
        if isEventChat {
            let pushMessagesRef = eventChatMessagesRef.child(documentID).child("pushMessages")
            
            let commaEmail = self.user!.email!.replacingOccurrences(of: ".", with: ",")
            
            self.eventChatMessagesRef.child(commaEmail).child("Chats").child(self.documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { snapshot in
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
                }
            }
        } else {
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
                }
            }
        }
    }
    
    /*func downloadImages() {
        for imageUrl in self.chatImagesArray {
            if let _ = self.defaults.dictionary(forKey: "\(self.documentID) photos") {
                if !currentChatImageDictionary.keys.contains(imageUrl) {
                    Amplify.Storage.downloadData(key: imageUrl) { result in
                        switch result {
                        case .success(let data):
                            print("Success downloading image downloadImages", data)
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.imageCache.setObject(image, forKey: imageUrl as NSString)
                                    if self.chatImagesArray.contains(imageUrl) && !self.currentChatImageDictionary.keys.contains(imageUrl) {
                                            self.currentChatImageDictionary[imageUrl] = data
                                            self.defaults.setValue(self.currentChatImageDictionary, forKey: "\(self.documentID) photos")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("failure downloading image", error)
                        }
                    }
                } else {
                    print("already contained downloadImages")
                }
            }
        }
    }*/
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
        
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
            
            let commaEmail = user.email!.replacingOccurrences(of: ".", with: ",")
            
            let conversationBadgeCountRef: DatabaseReference
            
            if isEventChat {
                conversationBadgeCountRef = eventChatsByUserRef.child(commaEmail).child("Chats").child(documentID).child("badgeCount")
            } else {
                conversationBadgeCountRef = groupChatByUsersRef.child(commaEmail).child("Chats").child(documentID).child("badgeCount")
            }
            
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
            
            if self.isEventChat {
                if section == self.keyArray.count {
                    return 1
                } else {
                    let key = reversedKeyArray[section]
                    return messages[key]!.count
                }
            } else {
                let key = reversedKeyArray[section]
                return messages[key]!.count
            }
            
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
            
            if isEventChat && indexPath.section == self.keyArray.count {
                print("XYZ")
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "eventInfoCell") as! EventInfoTableViewCell
                
                cell.eventDescriptionLabel.text = self.eventDescription
                cell.timeLabel.text = self.eventTime
                cell.dateLabel.text = self.eventDate
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
            
            var reversedKeyArray: [String] = []
            
            for value in self.keyArray.reversed() {
                reversedKeyArray.append(value)
            }
            
            let key = reversedKeyArray[indexPath.section]
            
            let sortedMessages = self.messages[key]!.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let message: Message
            
            if isEventChat {
                message = sortedMessages[indexPath.row]
            } else {
                message = sortedMessages[indexPath.row]
            }
            
            if indexPath.row < sortedMessages.count - 2 {
                let message2 = sortedMessages[indexPath.row + 1]
                if message2.imageURL != "" {
                    let NSImageURL = message2.imageURL! as NSString
                    if let _ = self.imageCache.object(forKey: NSImageURL) {
                        print("already contained")
                    } else if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") {
                        if let storedImageData = chatImageDictionary[message2.imageURL!] as? Data {
                            print("already contained")
                            self.imageCache.setObject(UIImage(data: storedImageData)!, forKey: NSImageURL as NSString)
                        }
                    }
                    else {
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
                
                cell.isGroupMessage = true
                
                cell.messageImageView.image = nil
                
                if isEventChat {
                    cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row - 1)
                } else {
                    cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
                }
                
                
                if message.messageSender == userFullName {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                
                //self.defaults.setValue(, forKey: "\(self.documentID) photos")
                
                
                
                
                
                cell.imageURL = message.imageURL!
                
                let imageURL = message.imageURL!
                
                let NSImageURL = message.imageURL! as NSString
                
                if let cachedImage = self.imageCache.object(forKey: NSImageURL as NSString) as? UIImage{
                    print("cell for row cache")
                    cell.messageImageView.image = cachedImage
                    let imageHeight = CGFloat(cachedImage.size.height/cachedImage.size.width * 300)
                    cell.imageHeight = imageHeight
                    if !self.chatImagesArray.contains(imageURL) {
                        self.currentChatImageDictionary.removeValue(forKey: imageURL)
                    }
                } else if let chatImageDictionary = self.defaults.dictionary(forKey: "\(self.documentID) photos") {
                    if let storedImageData = chatImageDictionary[imageURL] as? Data {
                        let image = UIImage(data: storedImageData)!
                        print("Already Contained group Chat Photo")
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
                 DispatchQueue.main.async {
                 cell.messageImageView.image = image
                 self.imageCache.setObject(image, forKey: NSImageURL as NSString)
                 if self.chatImagesArray.contains(imageURL) {
                 var chatImageDictionary: [String: Data] = [:]
                 chatImageDictionary[imageURL] = data
                 self.defaults.setValue(chatImageDictionary, forKey: "\(self.documentID) photos")
                 }
                 }
                 }
                 case .failure(let error):
                 print("failure downloading image", error)
                 }
                 }
                 }*/
                
                cell.isGroupMessage = true
                
                cell.emailLabel.text = message.messageSenderNickName
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                
                return cell
                
                
            } else if let event = message.event {
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "eventMessageCell", for: indexPath) as! EventTableViewCell
                
                cell.userFullName = self.userFullName
                cell.messageSender = message.messageSender
                cell.documentID = event.documentID
                cell.messageTimeStamp = message.timeStamp
                cell.groupChatDocumentID = self.documentID
                cell.titleTextField.text = event.title
                cell.timeTextField.text = "\(event.date) | \(event.time)"
                cell.bodyTextField.text = event.description
                cell.GroupChatVCInstace = self
                
                
                if event.eventCap == "No Limit" {
                    cell.eventCap.text = "No Limit"
                    cell.currentNumber.isHidden = true
                    cell.eventCap.isHidden = true
                    cell.fractionLine.isHidden = true
                } else {
                    cell.currentNumber.isHidden = false
                    cell.eventCap.isHidden = false
                    cell.fractionLine.isHidden = false
                    //cell.currentNumber.text = event.currentNumber
                    cell.eventCap.text = event.eventCap
                }
                
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                
                return cell
            } else {
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! BubbleMessageBodyCell
                
                cell.isGroupChat = true
                
                let chatImageUrl = message.messageSenderChatImage ?? "default"
                
                if chatImageUrl != "default" {
                    if let cachedImage = self.imageCache.object(forKey: chatImageUrl as NSString? ?? "") as? UIImage {
                        cell.profileImageView.image = cachedImage
                    } else if var imageDictionary = defaults.dictionary(forKey: "dmContactPictures")  {
                        if let storedImageData = imageDictionary[chatImageUrl] {
                            let image = UIImage(data: storedImageData as! Data)!
                            cell.profileImageView.image = image
                            let NSChatImageUrl = chatImageUrl as NSString
                            self.imageCache.setObject(image, forKey: NSChatImageUrl)
                        } else {
                            Amplify.Storage.downloadData(key: chatImageUrl) { result in
                                switch result {
                                case .success(let data):
                                    print("Success downloading image", data)
                                    if let image = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            cell.profileImageView.image = image
                                            self.imageCache.setObject(image, forKey: chatImageUrl as NSString)
                                            imageDictionary[chatImageUrl] = data
                                            self.defaults.setValue(imageDictionary, forKey: "dmContactPictures")
                                        }
                                    }
                                case .failure(let error):
                                    print("failure downloading image", error)
                                }
                            }
                        }
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "NewContactIcon")
                }
                
                cell.documentID = self.documentID
                cell.timeStamp = message.timeStamp
                
                if let messageBody = message.messageBody {
                    
                    cell.messageBody.text = messageBody
                    cell.messageTextView.text = messageBody
                    
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
                
                if isEventChat {
                    cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
                } else {
                    cell.groupPosition = checkCellPosition(sortedMessages: sortedMessages, indexPathRow: indexPath.row)
                }
                
                
                cell.isGroupMessage = true
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
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
        if tableView == self.pushMessagesTableView {
            return 1
        } else {
            if isEventChat {
                return keyArray.count + 1
            } else {
                return keyArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == pushMessagesTableView {
            return 0
        } else {
            return 20
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == chatTableView {
            
            if section == self.keyArray.count {
                let emptyFooterView = UIView()
                emptyFooterView.backgroundColor = UIColor(named: "WarmBlack")
                return emptyFooterView
            }
            
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
                headerLabel.text = dateString
                headerLabel.textColor = .white
                headerLabel.textAlignment = .center
                headerLabel.translatesAutoresizingMaskIntoConstraints = false
                headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
                
                let containerView = UIView()
                containerView.addSubview(headerLabel)
                containerView.backgroundColor = UIColor(named: "WarmBlack")
                
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
}

extension String {
    public var numArray: [String] {
        let characterSet = CharacterSet(charactersIn: "0123456789.").inverted
        return components(separatedBy: characterSet)
        
    }
}







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

class ChatViewController: UIViewController {
    
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
    //var conversationBadgeCountHandler: UInt?
    

    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.textBarAndButtonHolder.isHidden = false
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        
        /*let navigationBar = navigationController!.navigationBar
         navigationBar.barTintColor = UIColor.clear
         
         let navigationBarAppearence = UINavigationBarAppearance()
         navigationBarAppearence.shadowColor = .clear
         navigationBar.scrollEdgeAppearance = navigationBarAppearence*/
        
        
        
        
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        
        pushMessageButton.isEnabled = false
        pushMessageButton.tintColor = UIColor.clear
        
        
        
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textBarView.layer.cornerRadius = chatTextBar.bounds.height/2
        textBarView.layer.backgroundColor = UIColor.clear.cgColor
        textBarView.layer.borderWidth = 3
        textBarView.layer.borderColor =
            UIColor.white.cgColor//UIColor(named: "BrandPurpleColor")?.cgColor
        
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        loadMessages()
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
        
        if totalMessages <= 5 {
            bottomConstraint.constant = keyboardFrame
        } else {
            if (self.view.bounds.origin.y == 0) {
                //self.stackView.bounds.origin.y += (keyboardFrame - 42)
                // print(self.view.bounds.origin.y)
                self.view.bounds.origin.y += (keyboardFrame - 42)
                //print(self.view.bounds.origin.y)
            }
        }
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        pushMessageButton.isEnabled = false
        pushMessageButton.tintColor = UIColor.clear
        
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
            for value in postDict.values {
                if let messageSender = value.object(forKey: "messageSender")! as? String, let messageBody = value.object(forKey: "messageBody") as? String, let timeStamp = value.object(forKey: "timeStamp") as? Double {
                    self.totalMessages += 1
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
                        let indexPath = IndexPath(row: self.messages[self.keyArray.last!]!.count - 1, section: self.keyArray.count - 1)
                        //self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        
                    }
                    
                    /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                     
                     self.chatTableView.isHidden = false
                     self.textBarAndButtonHolder.isHidden = false
                     }*/
                }
            }
        })
        
        
        userBadgeCountRef.observe(DataEventType.value, with: { (snapshot) in
            print(snapshot.value)
            let postIntAsString = snapshot.value! as! String
            let postInt = Int(postIntAsString)
            UIApplication.shared.applicationIconBadgeNumber = postInt!
        })
        
        
        /*self.chatsByUserRef.child("\(commaUserEmail!)/Chats/\(commaDocumentName)/badgeCount").setValue("0")*/
        
        //UIApplication.shared.applicationIconBadgeNumber = 50
        
        
        /*db.collection("ChatMessages").document(documentName).collection("Messages").order(by: "timeStamp").addSnapshotListener { querySnapshot, err in
         if let err = err {
         print("Error getting documents: \(err)")
         } else {
         self.messages = []
         for document in querySnapshot!.documents {
         if let messageSender = document.data()["messageSender"] as? String, let messageBody = document.data()["messageBody"] as? String, let timeStamp =  document.data()["timeStamp"] as? Double {
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
         }*/
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
            
            if messageBody.contains("Venmo") && messageBodyHasNumbers {
                
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
        }

        
        //if message is only message in section
        if (indexPath.row == 0 && indexPath.row == sortedMessages.count - 1) {
            cell.groupPosition = "notOfGroup"
        }
        // if first message in section
        else if (indexPath.row == 0) {
            let message = sortedMessages[indexPath.row]
            let nextMessage = sortedMessages[indexPath.row + 1]
            
            if message.messageSender == nextMessage.messageSender {
                cell.groupPosition = "groupEnd"
            } else {
                cell.groupPosition = "notOfGroup"
            }
            
            //if last message of section
        } else if (indexPath.row == sortedMessages.count - 1) {
            let previousMessage = sortedMessages[indexPath.row - 1]
            let message = sortedMessages[indexPath.row]
            
            if previousMessage.messageSender == message.messageSender {
                cell.groupPosition = "groupStart"
            } else {
                cell.groupPosition = "notOfGroup"
            }
            //if in the middle of section
        } else {
            let previousMessage = sortedMessages[indexPath.row - 1]
            let message = sortedMessages[indexPath.row]
            let nextMessage = sortedMessages[indexPath.row + 1]
            
            if previousMessage.messageSender == message.messageSender {
                if message.messageSender == nextMessage.messageSender {
                    cell.groupPosition = "groupMiddle"
                } else {
                    cell.groupPosition = "groupStart"
                }
            } else if (message.messageSender == nextMessage.messageSender){
                cell.groupPosition = "groupEnd"
            } else {
                cell.groupPosition = "notOfGroup"
            }
        }
        cell.messageBody.text = message.messageBody
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
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








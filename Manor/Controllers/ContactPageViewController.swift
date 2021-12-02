//
//  ContactPageViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/12/21.
//

import UIKit
import Firebase
import DropDown
import Amplify
import AmplifyPlugins
import SwiftKeychainWrapper

class ContactPageViewController: UIViewController {
    
    @IBOutlet weak var guideView: UIView!
    //@IBOutlet weak var contactCollectionView: UICollectionView!
    @IBOutlet weak var createConversationButton: UIBarButtonItem!
    
    //--//
    
    let db = Firestore.firestore()
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    let groupChatMessages = Database.database().reference().child("GroupChatMessages")
    let eventChatsByUserRef =
    Database.database().reference().child("EventChatsByUser")
    let eventChatMessagesRef = Database.database().reference().child("EventChatMessages")
    let usersRef = Database.database().reference().child("users")
    let chatViewcontroller = ChatViewController()
    var ref: DocumentReference? = nil
    var user: User! = Firebase.Auth.auth().currentUser
    var otherUserFullName = ""
    var otherUserEmail: String = ""
    var userFullName: String = ""
    var contacts: [Contact] = []
    var eventContacts: [Contact] = []
    var groupChats: [String] = []
    let dropDown = DropDown()
    let flowLayout = UICollectionViewFlowLayout()
    var groupChatImageUrl: String = ""
    var segueProfileImageUrl: String = ""
    
    let imageCache = NSCache<NSString, AnyObject>()
    let defaults = UserDefaults.standard
    
    var isEventChat: Bool = false
    var documentID: String = ""
    var groupChatTitle: String = ""
    var groupMembers: [[String]] = []
    
    let eventFlowLayout = UICollectionViewFlowLayout()
    let groupChatScrollView = UIScrollView()
    let contentView = UIView()
    
    let contactCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    let eventChatCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    var contentViewHeightConstraints = NSLayoutConstraint()
    var eventChatCollectionViewHeightConstraint = NSLayoutConstraint()
    var contactCollectionViewHeightConstraint = NSLayoutConstraint()
    var smallEventChatCollectionViewConstraints: [NSLayoutConstraint]!
    var bigEventChatCollectionViewConstraints: [NSLayoutConstraint]!
    
    
    var eventLabel: UILabel = {
        let eventLabel = UILabel()
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        eventLabel.textColor = .white
        eventLabel.text = "My Events:"
        return eventLabel
    }()
    
    //--//
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateLayout()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateLayout() {
        let contactCollectionViewHeight = contactCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        contactCollectionViewHeightConstraint.constant = contactCollectionViewHeight
        
        //var eventHeight = EventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        //eventChatCollectionViewHeightConstraint.constant = eventHeight
        
        
        let eventCellWidth = UIScreen.main.bounds.width/3 - 10
        let eventCellHeight = eventCellWidth/0.775 + 5
        
        if self.eventContacts.count == 0  {
            eventChatCollectionViewHeightConstraint.constant = 0
            self.eventChatCollectionView.isHidden = true
            self.eventLabel.isHidden = true
            /*if self.contacts.count != 0 {
             self.separatorLine.isHidden = false
             } else {
             self.separatorLine.isHidden = true
             }*/
        } else {
            eventChatCollectionViewHeightConstraint.constant = eventCellHeight
            self.eventChatCollectionView.isHidden = false
            self.eventLabel.isHidden = false
        }
        
        /*if eventHeight == 10 || eventHeight == 15 {
         eventHeight = 10
         self.EventChatCollectionView.isHidden = true
         self.eventLabel.isHidden = true
         } else {
         self.EventChatCollectionView.isHidden = false
         self.eventLabel.isHidden = false
         }
         eventChatCollectionViewHeightConstraint.constant = eventHeight*/
        
        contentViewHeightConstraints.constant =  contactCollectionView.collectionViewLayout.collectionViewContentSize.height + eventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 10
        
    }
    
    
    func layoutViews() {
        
        self.view.addSubview(groupChatScrollView)
        groupChatScrollView.translatesAutoresizingMaskIntoConstraints = false
        groupChatScrollView.backgroundColor = UIColor(named: "Warmblack")
        
        let groupChatScrollViewConstraints = [
            groupChatScrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            groupChatScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            groupChatScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            groupChatScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(groupChatScrollViewConstraints)
        
        self.groupChatScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: groupChatScrollView.topAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: groupChatScrollView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: groupChatScrollView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: groupChatScrollView.bottomAnchor, constant: 0),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ]
        
        contentViewHeightConstraints = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        contentViewHeightConstraints.isActive = true
        
        NSLayoutConstraint.activate(contentViewConstraints)
        
        let eventCellWidth = UIScreen.main.bounds.width/5 - 10
        let eventCellHeight = eventCellWidth/0.825
        
        self.contentView.addSubview(eventChatCollectionView)
        eventChatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        eventChatCollectionView.backgroundColor = .clear//UIColor(named: K.BrandColors.purple)
        eventChatCollectionView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        eventChatCollectionView.layer.borderWidth = 3
        eventChatCollectionView.isScrollEnabled = true
        eventChatCollectionView.layer.cornerRadius = 15
        
        smallEventChatCollectionViewConstraints = [
            eventChatCollectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            eventChatCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            eventChatCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            //eventChatCollectionView.bottomAnchor.constraint(equalTo: contactCollectionView.topAnchor, constant: 0)
            eventChatCollectionView.heightAnchor.constraint(equalToConstant: eventCellHeight + 20)
        ]
        
        bigEventChatCollectionViewConstraints = [
            eventChatCollectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            eventChatCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            eventChatCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            //eventChatCollectionView.bottomAnchor.constraint(equalTo: contactCollectionView.topAnchor, constant: 0)
            eventChatCollectionView.heightAnchor.constraint(equalToConstant: eventCellHeight + 20)
        ]
        
        eventChatCollectionViewHeightConstraint = eventChatCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        eventChatCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate(smallEventChatCollectionViewConstraints)
        
        self.contentView.addSubview(contactCollectionView)
        contactCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contactCollectionView.backgroundColor = .clear
        contactCollectionView.isScrollEnabled = false
        
        
        let contactCollectionViewConstraints = [
            contactCollectionView.topAnchor.constraint(equalTo: eventChatCollectionView.bottomAnchor, constant: 5),
            contactCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            contactCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            contactCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ]
        
        contactCollectionViewHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        contactCollectionViewHeightConstraint.isActive = true
        
        //let contactCollectionViewHeightConstraint = contactCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        //contactCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate(contactCollectionViewConstraints)
        
        
        
        /*self.contentView.addSubview(eventLabel)
         
         let eventLabelConstraints = [
         eventLabel.topAnchor.constraint(equalTo: EventChatCollectionView.topAnchor, constant: 5),
         eventLabel.leadingAnchor.constraint(equalTo: EventChatCollectionView.leadingAnchor, constant: 10)
         ]
         
         NSLayoutConstraint.activate(eventLabelConstraints)*/
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
        
        groupChatScrollView.delegate = self
        
        /*let eventCollectionViewLayout = eventChatCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
         
         collectionViewLayout?.sectionInset = ... // some UIEdgeInset
         
         collectionViewLayout?.invalidateLayout()
         
         
         eventChatCollectionView.contentInset*/
        
        self.layoutViews()
        
        self.contactCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        self.eventChatCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        
        //shows navigation bar
        //navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationItem.title = "Messages"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "WarmBlack")
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
        
        
        
        //sets size, scroll direction, etc. of contacts in collection view
        let cellWidth = UIScreen.main.bounds.width/2 - 10
        let cellHeight = cellWidth/0.8244
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight) //235
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5.0
        contactCollectionView.collectionViewLayout = flowLayout
        
        let littleCellWidth = UIScreen.main.bounds.width/5
        let littleCellHeight = littleCellWidth/0.825 //750
        
        eventFlowLayout.itemSize = CGSize(width: littleCellWidth, height: littleCellHeight) //235
        eventFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        eventFlowLayout.scrollDirection = .horizontal
        eventFlowLayout.minimumInteritemSpacing = 0.0
        eventChatCollectionView.collectionViewLayout = eventFlowLayout
        
        
        //sets up drop down for choosing between new DM or group chat
        dropDown.anchorView = guideView
        dropDown.dataSource = ["New Direct Message", "New Group Chat"]
        //let screenSize: CGRect = UIScreen.main.bounds
        //let screenWidth = screenSize.width
        //dropDown.width = screenWidth - 40
        //dropDown.bottomOffset = CGPoint(x: 20, y:0)
        dropDown.backgroundColor =
        UIColor.darkGray
        //UIColor(named: K.BrandColors.navigationBarGray)
        DropDown.appearance().cellHeight = 60
        dropDown.selectionAction = { (index: Int, item: String) in
            if (item == "New Direct Message") {
                self.performSegue(withIdentifier: K.Segues.newDirectMessageSegue, sender: self)
            }
            
            if (item == "New Group Chat") {
                self.performSegue(withIdentifier: K.Segues.newGroupMessageSegue, sender: self)
            }
        }
        dropDown.willShowAction = {
            DropDown.appearance().selectionBackgroundColor = //UIColor(named: K.BrandColors.backgroundBlack)!
            UIColor.darkGray
        }
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        title = "Messages"
        
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        eventChatCollectionView.delegate = self
        eventChatCollectionView.dataSource = self
        loadContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let email = defaults.string(forKey: "savedEmail"), let password =
            KeychainWrapper.standard.string(forKey: "savedPassword") {
            self.checkSignInStatus(email: email, password: password)
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    func checkSignInStatus(email: String, password: String) {
        let commaUserName = email.replacingOccurrences(of: ".", with: ",")
        /*Auth.auth().addStateDidChangeListener { (auth, user) in
         print("complete")
         print(user)
         if user == nil {
         print("no user")
         } else {
         print("Firebase User Exists")
         }
         }*/
        
        Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                if !session.isSignedIn {
                    self.signIn(username: commaUserName, password: password, isFirstTry: true)
                }
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }
    
    func signIn(username: String, password: String, isFirstTry: Bool) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                DispatchQueue.main.async {
                    self.contactCollectionView.reloadData()
                    //self.bigGroupChatCollectionView.reloadData()
                    //self.littleGroupChatCollectionView.reloadData()
                    //self.EventChatCollectionView.reloadData()
                }
            case .failure(let error):
                print("Sign in failed \(error)")
                if isFirstTry {
                    Amplify.Auth.signOut { result in
                        switch result {
                        case .success:
                            print("success signing out")
                            DispatchQueue.main.async {
                                self.signIn(username: username, password: password, isFirstTry: false)
                            }
                        case .failure(let error):
                            print("Sign out failed \(error)")
                        }
                    }
                } else {
                    print(error)
                    let email = username.replacingOccurrences(of: ",", with: ".")
                    self.signUp(username: username, password: password, email: email)
                    /*DispatchQueue.main.async {
                     let alert = UIAlertController(title: "Login Failed", message: "\(error)", preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                     alert.dismiss(animated: true)
                     }))
                     self.present(alert, animated: true)
                     }*/
                }
            }
        }
    }
    
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let key):
                print("Success!", key)
                self.signIn(username: username, password: password, isFirstTry: true)
            case .failure(let error):
                print("Sign up failed", error)
                /*let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { UIAlertAction in
                 alert.dismiss(animated: true)
                 }))*/
            }
        }
    }
    
    //gives chat view controller otherUserFullName, otherUserEmail, and userFullName
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChatViewController {
            let vc = segue.destination as! ChatViewController
            vc.otherUserFullName = self.otherUserFullName
            vc.otherUserEmail = self.otherUserEmail
            vc.userFullName = self.userFullName
            vc.barButtonProfileImageUrl = self.segueProfileImageUrl
            
            if(user.email! < otherUserEmail ) {
                let chatTitle = "\(self.user!.email!) + \(otherUserEmail)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            } else {
                let chatTitle = "\(otherUserEmail) + \(self.user!.email!)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            }
        } else if segue.destination is GroupChatViewController {
            let vc = segue.destination as! GroupChatViewController
            vc.documentID = self.documentID
            vc.groupChatTitle = self.groupChatTitle
            vc.groupMembers = self.groupMembers
            vc.groupChatImageUrl = self.groupChatImageUrl
            vc.isEventChat = self.isEventChat
        }
    }
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == groupChatScrollView {
            
            guard let navigationController = self.navigationController else { return }
            let navBarHeight = navigationController.navigationBar.frame.height
            //let threshold: CGFloat = 20
            //let alpha = (scrollView.contentOffset.y + navBarHeight + threshold) / threshold
            let alpha: CGFloat = (scrollView.contentOffset.y + 88)/100
            navigationController.navigationBar.subviews.first?.alpha = 1
        } else if scrollView == eventChatCollectionView {
            
        }
    }*/
    
    @IBAction func CreateNewMessagePressed(_ sender: Any) {
        dropDown.show()
    }
    
    //listend loads and continues to listen for new objects under chatsByUser.userEmail.Chats
    //has otherUserEmail, otherUserFullName, and timeStamp as empty to be filled in with values from this ref
    //creates contact value and appends to contacts array and reloads collection view data
    func loadContacts() {
        guard let userEmail = self.user?.email! else {
            return
        }
        let commaEmail = userEmail.replacingOccurrences(of: ".", with: ",")
        let userChatsRef = chatsByUserRef.child(commaEmail).child("Chats")
        
        userChatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            var otherUserEmail: String = ""
            self.contacts = self.contacts.filter({ contact in
                return contact.DM == false
            })
            for (key,value) in postDict {
                let userEmails = key.components(separatedBy: " + ")
                if (userEmails[0] != commaEmail) {
                    otherUserEmail = userEmails[0].replacingOccurrences(of: ",", with: ".")
                } else {
                    otherUserEmail = userEmails[1].replacingOccurrences(of: ",", with: ".")
                }
                
                if otherUserEmail != "" {
                    let commaOtherUserEmail = otherUserEmail.replacingOccurrences(of: ".", with: ",")
                    self.usersRef.child(commaOtherUserEmail).child("profileImageUrl").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                        let profileImageUrl = DataSnapshot.value as? String
                        userChatsRef.child("\(key)/profileImageUrl").setValue(profileImageUrl)
                    }
                }
                
                
                if let otherUserFullName = value.object(forKey: "title") as? String, let timeStamp = value.object(forKey: "timeStamp") as? Double, let lastMessage = value.object(forKey: "lastMessage") as? String {
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    
                    let profileImageUrl = value.object(forKey: "profileImageUrl") as? String ?? "default"
                    
                    let badgeCount = Int(stringBadgeCount)
                    
                    
                    
                    let userContact = Contact(email: otherUserEmail, fullName: otherUserFullName, timeStamp: timeStamp, lastMessage: lastMessage, badgeCount: badgeCount!, profileImageUrl: profileImageUrl, DM: true)
                    
                    
                    self.contacts.append(userContact)
                }
                
                DispatchQueue.main.async {
                    self.contactCollectionView.reloadData()
                    self.updateLayout()
                }
            }
        })
        
        let chatsRef = groupChatsByUserRef.child(commaEmail).child("Chats")
        
        chatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.contacts = self.contacts.filter({ contact in
                return contact.DM == true
            })
            for value in postDict.values {
                if let groupChatTitle = value.object(forKey: "title") as? String, let groupChatDocumentID = value.object(forKey: "documentID") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    
                    let timeStamp = commaTimeStamp.replacingOccurrences(of: ",", with: ".")
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    let badgeCount = Int(stringBadgeCount)
                    
                    let lastMessage = value.object(forKey: "lastMessage") as? String ?? ""
                    
                    let profileImageUrl = value.object(forKey: "profileImageUrl") as? String ?? "default"
                    
                    self.groupChatImageUrl = profileImageUrl
                    
                    
                    let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: lastMessage, badgeCount: badgeCount!, profileImageUrl: profileImageUrl, DM: false)
                    
                    self.contacts.append(groupChatContact)
                }
            }
            DispatchQueue.main.async {
                self.contactCollectionView.reloadData()
                self.updateLayout()
            }
        })
        
        
        let eventChatsRef = eventChatsByUserRef.child(commaEmail).child("Chats")
        
        eventChatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.eventContacts = []
            for value in postDict.values {
                if let groupChatTitle = value.object(forKey: "title") as? String, let groupChatDocumentID = value.object(forKey: "documentID") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    
                    let timeStamp = commaTimeStamp.replacingOccurrences(of: ",", with: ".")
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    
                    let badgeCount = Int(stringBadgeCount)
                    
                    let profileImageUrl = value.object(forKey: "profileImageUrl") as? String ?? "default"
                    
                    self.groupChatImageUrl = profileImageUrl
                    
                    let eventDescription = value.object(forKey: "eventDescription") as? String ?? "Error"
                    let eventDate = value.object(forKey: "eventDate") as? String ?? "Error"
                    let eventTime = value.object(forKey: "eventTime") as? String ?? "Error"
                    
                    let event = Event(title: groupChatTitle, description: eventDescription, date: eventDate, time: eventTime, documentID: nil)
                    
                    let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: "", badgeCount: badgeCount!, profileImageUrl: profileImageUrl, event: event, DM: true)
                    
                    self.eventContacts.append(groupChatContact)
                }
            }
            DispatchQueue.main.async {
                self.updateLayout()
                self.eventChatCollectionView.reloadData()
            }
        })
        
        
        
        /*db.collection("ChatsByUser").document("\(String(describing: self.user!.email!))").collection("Chats").order(by: "timeStamp", descending: true).addSnapshotListener { (querySnapshot, err) in
         if let err = err {
         print("Error getting documents: \(err)")
         } else {
         self.contacts = []
         if (querySnapshot!.documents.isEmpty) {
         print("No documents in Snapshot")
         } else {
         for document in querySnapshot!.documents {
         let userEmails = document.documentID.components(separatedBy: " + ")
         var userEmail = ""
         if (userEmails[0] != self.user!.email!) {
         userEmail = userEmails[0]
         } else {
         userEmail = userEmails[1]
         }
         let userFullName = document.data()["title"]
         let userContact = Contact(email: userEmail, fullName: userFullName as! String)
         self.contacts.append(userContact)
         DispatchQueue.main.async {
         self.contactCollectionView.reloadData()
         }
         }
         }
         }
         }*/
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeDMTitleBold"), object: nil)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //let alpha: CGFloat = (self.contactCollectionView.contentOffset.y + 88)/100
        //navigationController?.navigationBar.subviews.first?.alpha = alpha
    }
}

extension ContactPageViewController: UICollectionViewDataSource {
    //sets count for how many objects there will be in collection view based on how many obejcts are in contacts array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.contactCollectionView {
            return contacts.count
        } else {
            return eventContacts.count
        }
    }
    
    //creates each cell as ContactCollectionViewCell, sorts the contacts array by timestamp, and then sets the nameLabel of the cell to fullName and the documentID of cell to email
    //documentID is set to email just to have the cell hold that info for when it is selected so this view controller can pass the otherUserEmail to the chatviewcontroller
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.contactCollectionView {
            let cell = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
            
            cell.isMainFour = true
            
            let sortedContacts = self.contacts.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            //cell.nameLabel.text = sortedContacts[indexPath.row].fullName
            
            if sortedContacts[indexPath.row].badgeCount == 0 {
                cell.hasUnreadMessages = false
            } else {
                cell.hasUnreadMessages = true
            }
            
            cell.lastMessageLabel.text = sortedContacts[indexPath.row].lastMessage
            cell.contactName.text = sortedContacts[indexPath.row].fullName
            cell.documentID = sortedContacts[indexPath.row].email
            cell.profileImageUrl = sortedContacts[indexPath.row].profileImageUrl
            cell.DM = sortedContacts[indexPath.row].DM
            
            let profileImageUrl = sortedContacts[indexPath.row].profileImageUrl
            
            cell.profileImageUrl = profileImageUrl
            cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            
            if profileImageUrl == "default" || profileImageUrl == "" {
                return cell
            } else {
                if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                    cell.contactImageView.image = cachedImage as? UIImage
                } else if var imageDictionary = defaults.dictionary(forKey: "contactPictures") {
                    if let storedImageData = imageDictionary[profileImageUrl] {
                        let image = UIImage(data: storedImageData as! Data)
                        cell.contactImageView.image = image
                        let NSProfileImageUrl = profileImageUrl as NSString
                        self.imageCache.setObject(image!, forKey: NSProfileImageUrl)
                    } else {
                        Amplify.Storage.downloadData(key: profileImageUrl) { result in
                            switch result {
                            case .success(let data):
                                if let image = UIImage(data: data) {
                                    //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                    DispatchQueue.main.async {
                                        cell.contactImageView.image = image
                                        self.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                                        imageDictionary[profileImageUrl] = data
                                        self.defaults.setValue(imageDictionary, forKey: "contactPictures")
                                    }
                                }
                            case .failure(let error):
                                print("failure downloading image", error)
                            }
                        }
                    }
                }
            }
            return cell
        } else {
            let cell = eventChatCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
            
            let sortedContacts = self.eventContacts.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let contact = sortedContacts[indexPath.row]
            
            cell.isMainFour = false
            
            if contact.badgeCount == 0 {
                cell.hasUnreadMessages = false
            } else {
                cell.hasUnreadMessages = true
            }
            
            cell.contactName.text = contact.fullName
            cell.documentID = contact.email
            cell.members = contact.members
            cell.lastMessageLabel.text = contact.lastMessage
            cell.eventDescription = contact.event?.description ?? ""
            cell.eventDate = contact.event?.date ?? ""
            cell.eventTime = contact.event?.time ?? ""
            
            let profileImageUrl = contact.profileImageUrl
            
            cell.profileImageUrl = profileImageUrl
            cell.contactImageView.image = #imageLiteral(resourceName: "Beach")
            
            if profileImageUrl == "default" || profileImageUrl == "" {
                return cell
            } else {
                if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                    cell.contactImageView.image = cachedImage as? UIImage
                } else if var imageDictionary = defaults.dictionary(forKey: "contactPictures") {
                    if let storedImageData = imageDictionary[profileImageUrl] {
                        let image = UIImage(data: storedImageData as! Data)
                        cell.contactImageView.image = image
                        let NSProfileImageUrl = profileImageUrl as NSString
                        self.imageCache.setObject(image!, forKey: NSProfileImageUrl)
                    } else {
                        Amplify.Storage.downloadData(key: profileImageUrl) { result in
                            switch result {
                            case .success(let data):
                                if let image = UIImage(data: data) {
                                    //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                    DispatchQueue.main.async {
                                        cell.contactImageView.image = image
                                        self.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                                        imageDictionary[profileImageUrl] = data
                                        self.defaults.setValue(imageDictionary, forKey: "contactPictures")
                                    }
                                }
                            case .failure(let error):
                                print("failure downloading image", error)
                            }
                        }
                    }
                }
            }
            return cell
        }
    }
}

//once the ContactCollectionViewCell is selected, its nameLabel and documentID properties are used to assign to otherUserFullName and otherUserEmail to be passed on to other VC
extension ContactPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.contactCollectionView {
            if let cell = contactCollectionView.cellForItem(at: indexPath) as? TestCollectionViewCell {
                
                if cell.DM {
                    self.otherUserFullName = cell.contactName.text ?? ""
                    self.otherUserEmail = cell.documentID
                    self.segueProfileImageUrl = cell.profileImageUrl
                    performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
                } else {
                    self.isEventChat = false
                    
                    self.documentID = cell.documentID
                    self.groupChatTitle = cell.contactName.text ?? ""
                    self.groupChatImageUrl = cell.profileImageUrl ?? "default"
                    
                    let MembersRef = groupChatMessages.child(documentID).child("Members")
                    
                    MembersRef.observe(DataEventType.value, with: { (snapshot) in
                        let postArray = snapshot.value as? [[String]] ?? [["FAILED"]]
                        self.groupMembers = postArray
                        self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
                    })
                }
            }
        } else {
            let cell = eventChatCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
            
            self.isEventChat = true
            self.documentID = cell.documentID
            self.groupChatTitle = cell.contactName.text ?? ""
            self.groupChatImageUrl = cell.profileImageUrl ?? "default"
            //self.eventDescription =  cell.eventDescription
            //self.eventTime = cell.eventTime
            //self.eventDate = cell.eventDate
            
            let MembersRef = eventChatMessagesRef.child(documentID).child("Members")
            
            MembersRef.observe(DataEventType.value, with: { (snapshot) in
                let postArray = snapshot.value as? [[String]] ?? [["FAILED"]]
                self.groupMembers = postArray
                self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
            })
        }
    }
}



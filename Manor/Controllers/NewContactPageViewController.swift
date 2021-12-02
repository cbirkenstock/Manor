//
//  NewContactPageViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/25/21.
//

import UIKit
import Firebase
import DropDown
import Amplify
import AmplifyPlugins
import SwiftKeychainWrapper

class NewContactPageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var guideView: UIView!
    //@IBOutlet weak var contactCollectionView: UICollectionView!
    @IBOutlet weak var createConversationButton: UIBarButtonItem!
    
    //--//
    
    let db = Firestore.firestore()
    var ref: DocumentReference?
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    let groupChatMessages = Database.database().reference().child("GroupChatMessages")
    let eventChatsByUserRef =
        Database.database().reference().child("EventChatsByUser")
    let eventChatMessagesRef = Database.database().reference().child("EventChatMessages")
    let chatViewController = ChatViewController()
    let firebaseManager = FirebaseManagerViewController()
    
    let dropDown = DropDown()
    let bigFlowLayout = UICollectionViewFlowLayout()
    let littleFlowLayout = UICollectionViewFlowLayout()
    let eventFlowLayout = UICollectionViewFlowLayout()
    
    var user: User! = Firebase.Auth.auth().currentUser
    var userFullName: String = ""
    var documentID: String = ""
    
    var contacts: [Contact] = []
    var eventContacts: [Contact] = []
    var groupChats: [String] = []
    var groupChatTitle: String = ""
    var groupMembers: [[String]] = []
    var groupChatImageUrl: String = ""
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    
    let imageCache = NSCache<NSString, AnyObject>()
    let defaults = UserDefaults.standard
    
    let groupChatScrollView = UIScrollView()
    let contentView = UIView()
    let testView = UIView()
    let testView2 = UIView()
    //var contactCollectionView =  UICollectionView()
    let bigGroupChatCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    let littleGroupChatCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    let EventChatCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    var littleCollectionViewHeightConstraint = NSLayoutConstraint()
    var bigCollectionViewHeightConstraint = NSLayoutConstraint()
    var eventChatCollectionViewHeightConstraint = NSLayoutConstraint()
    var contentViewHeightConstraints = NSLayoutConstraint()
    
    var isEventChat: Bool?
    
    var eventLabel: UILabel = {
        let eventLabel = UILabel()
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        eventLabel.textColor = .white
        eventLabel.text = "My Events:"
        return eventLabel
    }()
    
    var separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor(named: K.BrandColors.purple)
        return separatorLine
    }()
    
    var eventDescription: String = ""
    var eventDate: String = ""
    var eventTime: String = ""
    
    //--//
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = defaults.string(forKey: "savedEmail"), let password =
            KeychainWrapper.standard.string(forKey: "savedPassword") {
            self.checkSignInStatus(email: email, password: password)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeGroupChatTitleBold"), object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let littleHeight = littleGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        littleCollectionViewHeightConstraint.constant = littleHeight
        
        let bigHeight = bigGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        bigCollectionViewHeightConstraint.constant = bigHeight
        
        print("height")
        print(bigHeight)
        
        //var eventHeight = EventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        //eventChatCollectionViewHeightConstraint.constant = eventHeight
        
        
        let eventCellWidth = UIScreen.main.bounds.width/3 - 10
        let eventCellHeight = eventCellWidth/0.875 + 5
        
        if self.eventContacts.count == 0  {
            eventChatCollectionViewHeightConstraint.constant = 10
            self.EventChatCollectionView.isHidden = true
            self.eventLabel.isHidden = true
            if self.contacts.count != 0 {
                self.separatorLine.isHidden = false
            } else {
                self.separatorLine.isHidden = true
            }
        } else {
            eventChatCollectionViewHeightConstraint.constant = eventCellHeight + 20
            self.EventChatCollectionView.isHidden = false
            self.eventLabel.isHidden = false
            self.separatorLine.isHidden = true
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
        
        contentViewHeightConstraints.constant = littleGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + bigGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + EventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 15
        
        
    }
    
    func updateLayout() {
        let littleHeight = littleGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        littleCollectionViewHeightConstraint.constant = littleHeight
        
        let bigHeight = bigGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        bigCollectionViewHeightConstraint.constant = bigHeight
        
        //var eventHeight = EventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 5
        //eventChatCollectionViewHeightConstraint.constant = eventHeight
        
        
        let eventCellWidth = UIScreen.main.bounds.width/3 - 10
        let eventCellHeight = eventCellWidth/0.875 + 5
        
        if self.eventContacts.count == 0  {
            eventChatCollectionViewHeightConstraint.constant = 10
            self.EventChatCollectionView.isHidden = true
            self.eventLabel.isHidden = true
            if self.contacts.count != 0 {
                self.separatorLine.isHidden = false
            } else {
                self.separatorLine.isHidden = true
            }
            
        } else {
            eventChatCollectionViewHeightConstraint.constant = eventCellHeight + 20
            self.EventChatCollectionView.isHidden = false
            self.eventLabel.isHidden = false
            self.separatorLine.isHidden = true
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
        
        contentViewHeightConstraints.constant = littleGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + bigGroupChatCollectionView.collectionViewLayout.collectionViewContentSize.height + EventChatCollectionView.collectionViewLayout.collectionViewContentSize.height + 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(groupChatScrollView)
        groupChatScrollView.translatesAutoresizingMaskIntoConstraints = false
        groupChatScrollView.backgroundColor = UIColor(named: "Warmblack")
        
        let groupChatScrollViewConstraints = [
            groupChatScrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            groupChatScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            groupChatScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            groupChatScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            //groupChatScrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 1800)
        ]
        
        NSLayoutConstraint.activate(groupChatScrollViewConstraints)
        
        self.groupChatScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: groupChatScrollView.topAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: groupChatScrollView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: groupChatScrollView.trailingAnchor, constant: -0),
            contentView.bottomAnchor.constraint(equalTo: groupChatScrollView.bottomAnchor, constant: 0),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            //contentView.heightAnchor.constraint(equalToConstant: 10000)
        ]
        
        contentViewHeightConstraints = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        contentViewHeightConstraints.isActive = true
        
        NSLayoutConstraint.activate(contentViewConstraints)
        
        self.contentView.addSubview(bigGroupChatCollectionView)
        bigGroupChatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bigGroupChatCollectionView.backgroundColor = .clear
        bigGroupChatCollectionView.isScrollEnabled = false
        
        let bigGroupCollectionViewConstraints = [
            bigGroupChatCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            bigGroupChatCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            bigGroupChatCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            //bigGroupChatCollectionView.heightAnchor.constraint(equalToConstant: cellHeight * 2)
        ]
        
        bigCollectionViewHeightConstraint = bigGroupChatCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        bigCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate(bigGroupCollectionViewConstraints)
        
        self.view.addSubview(separatorLine)
        
        let separatorLineConstraints = [
            separatorLine.topAnchor.constraint(equalTo: bigGroupChatCollectionView.bottomAnchor, constant: 5),
            separatorLine.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            separatorLine.heightAnchor.constraint(equalToConstant: 2)
        ]
        
        NSLayoutConstraint.activate(separatorLineConstraints)
        
        self.contentView.addSubview(EventChatCollectionView)
        EventChatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        EventChatCollectionView.backgroundColor = UIColor(named: K.BrandColors.purple)
        EventChatCollectionView.isScrollEnabled = true
        EventChatCollectionView.layer.cornerRadius = 20
        
        let eventCellWidth = UIScreen.main.bounds.width/3 - 10
        let eventCellHeight = eventCellWidth/0.875 + 5
        
        let eventChatCollectionViewConstraints = [
            EventChatCollectionView.topAnchor.constraint(equalTo: self.bigGroupChatCollectionView.bottomAnchor, constant: 0),
            EventChatCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            EventChatCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            //EventChatCollectionView.heightAnchor.constraint(equalToConstant: eventCellHeight + 20)
        ]
        
        eventChatCollectionViewHeightConstraint = EventChatCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        eventChatCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate(eventChatCollectionViewConstraints)
        
        self.contentView.addSubview(eventLabel)
        
        let eventLabelConstraints = [
            eventLabel.topAnchor.constraint(equalTo: EventChatCollectionView.topAnchor, constant: 5),
            eventLabel.leadingAnchor.constraint(equalTo: EventChatCollectionView.leadingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(eventLabelConstraints)
        
        self.contentView.addSubview(littleGroupChatCollectionView)
        littleGroupChatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        littleGroupChatCollectionView.backgroundColor = .clear
        littleGroupChatCollectionView.isScrollEnabled = false
        
        let littleGroupCollectionViewConstraints = [
            littleGroupChatCollectionView.topAnchor.constraint(equalTo: self.EventChatCollectionView.bottomAnchor, constant: 0),
            littleGroupChatCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            littleGroupChatCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            //littleGroupChatCollectionView.heightAnchor.constraint(equalToConstant: 5000)
        ]
        
        littleCollectionViewHeightConstraint = littleGroupChatCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        littleCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate(littleGroupCollectionViewConstraints)
        
        /*self.contentView.addSubview(testView)
         testView.translatesAutoresizingMaskIntoConstraints = false
         testView.backgroundColor = .green
         
         let testViewConstraints = [
         testView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
         testView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
         testView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
         testView.heightAnchor.constraint(equalToConstant: 800)
         ]
         
         NSLayoutConstraint.activate(testViewConstraints)
         
         self.contentView.addSubview(testView2)
         testView2.translatesAutoresizingMaskIntoConstraints = false
         testView2.backgroundColor = .blue
         
         let testView2Constraints = [
         testView2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
         testView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
         testView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
         testView2.heightAnchor.constraint(equalToConstant: 800)
         ]
         
         NSLayoutConstraint.activate(testView2Constraints)*/
        
        //groupChatScrollView.contentSize = CGSize(width: self.view.bounds.width, height: 1600)
        
        self.bigGroupChatCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        self.bigGroupChatCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "testTwoCell")
        
        self.littleGroupChatCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        self.littleGroupChatCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "testTwoCell")
        
        self.EventChatCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        self.EventChatCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "testTwoCell")
        
        title = "Messages"
        
        //shows navigation bar
        //navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: false)
        
        /*navigationController?.navigationBar.isHidden = false
         navigationController?.navigationBar.isTranslucent = false
         navigationController?.navigationBar.barTintColor = .black
         navigationController?.navigationBar.shadowImage = UIImage()
         //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
         self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)*/
        
        bigGroupChatCollectionView.delegate = self
        bigGroupChatCollectionView.dataSource = self
        littleGroupChatCollectionView.delegate = self
        littleGroupChatCollectionView.dataSource = self
        EventChatCollectionView.delegate = self
        EventChatCollectionView.dataSource = self
        groupChatScrollView.delegate = self
        
        //sets size, scroll direction, etc. of contacts in collection view
        let cellWidth = UIScreen.main.bounds.width/2 - 10
        let bigCellWidth = UIScreen.main.bounds.width/2 - 10
        let bigCellHeight = cellWidth/0.8244
        bigFlowLayout.itemSize = CGSize(width: bigCellWidth, height: bigCellHeight) //235
        bigFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        bigFlowLayout.scrollDirection = .vertical
        bigFlowLayout.minimumInteritemSpacing = 5.0
        bigGroupChatCollectionView.collectionViewLayout = bigFlowLayout
        
        //sets size, scroll direction, etc. of contacts in collection view
        let littleCellWidth = UIScreen.main.bounds.width/3 - 10
        let littleCellHeight = littleCellWidth/0.875
        littleFlowLayout.itemSize = CGSize(width: littleCellWidth, height: littleCellHeight) //235
        littleFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        littleFlowLayout.scrollDirection = .vertical
        littleFlowLayout.minimumInteritemSpacing = 5.0
        littleGroupChatCollectionView.collectionViewLayout = littleFlowLayout
        
        eventFlowLayout.itemSize = CGSize(width: littleCellWidth, height: littleCellHeight) //235
        eventFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: -10, right: 5)
        eventFlowLayout.scrollDirection = .horizontal
        eventFlowLayout.minimumInteritemSpacing = 5.0
        EventChatCollectionView.collectionViewLayout = eventFlowLayout
        
        //sets up drop down for choosing between new DM or group chat
        dropDown.anchorView = guideView
        dropDown.dataSource = ["New Direct Message", "New Group Chat"]
        //let screenSize: CGRect = UIScreen.main.bounds
        //let screenWidth = screenSize.width
        //dropDown.width = screenWidth - 40
        //dropDown.bottomOffset = CGPoint(x: 20, y:0)
        dropDown.backgroundColor = //UIColor(named: K.BrandColors.backgroundBlack)
            UIColor.darkGray
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
        
        loadContacts()
        
    }
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        guard let navigationController = self.navigationController else { return }
        let navBarHeight = navigationController.navigationBar.frame.height
        let threshold: CGFloat = 0
        let alpha = (scrollView.contentOffset.y + navBarHeight + threshold) / threshold
        navigationController.navigationBar.subviews.first?.alpha = alpha
    }*/
    
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
                    self.bigGroupChatCollectionView.reloadData()
                    self.littleGroupChatCollectionView.reloadData()
                    self.EventChatCollectionView.reloadData()
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
    
    
    //passes documentID and groupChatTitle to groupChatView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is GroupChatViewController {
            let vc = segue.destination as! GroupChatViewController
            vc.documentID = self.documentID
            vc.groupChatTitle = self.groupChatTitle
            vc.groupMembers = self.groupMembers
            vc.groupChatImageUrl = self.groupChatImageUrl
            vc.isEventChat = self.isEventChat
            /*if self.isEventChat ?? false {
                vc.eventDescription = self.eventDescription
                vc.eventDate = self.eventDate
                vc.eventTime = self.eventTime
            }*/
        }
    }
    
    func addDividerLine() {
        let cellWidth = UIScreen.main.bounds.width/2 - 10
        let cellHeight = cellWidth/0.8244
        
        let lineYOrigin = (cellHeight * 2) + 60
        
        let line = CGRect(x: 0, y: lineYOrigin, width: UIScreen.main.bounds.width, height: 1)
        let lineView = UIView(frame: line)
        lineView.backgroundColor = UIColor(named: K.BrandColors.purple)
        
        self.view.addSubview(lineView)
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    
    @IBAction func CreateNewMessagePressed(_ sender: Any) {
        dropDown.show()
    }
    
    //loads and continues to listen for new objects under GroupChatsByUser.userEmail.Chats
    //pulls down groupChattitle, documentID, and timeStamp to create contact type and add to array
    func loadContacts() {
        let userEmail = self.user!.email!
        let commaEmail = userEmail.replacingOccurrences(of: ".", with: ",")
        
        let chatsRef = groupChatsByUserRef.child(commaEmail).child("Chats")
        
        chatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.contacts = []
            for value in postDict.values {
                if let groupChatTitle = value.object(forKey: "title") as? String, let groupChatDocumentID = value.object(forKey: "documentID") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    
                    let timeStamp = commaTimeStamp.replacingOccurrences(of: ",", with: ".")
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    let badgeCount = Int(stringBadgeCount)
                    
                    let lastMessage = value.object(forKey: "lastMessage") as? String ?? ""
                    
                    let profileImageUrl = value.object(forKey: "profileImageUrl") as? String ?? "default"
                    
                    self.groupChatImageUrl = profileImageUrl
                    
                    
                    let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: lastMessage, badgeCount: badgeCount!, profileImageUrl: profileImageUrl, DM: true)
                    
                    self.contacts.append(groupChatContact)
                }
            }
            DispatchQueue.main.async {
                self.bigGroupChatCollectionView.reloadData()
                self.littleGroupChatCollectionView.reloadData()
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
                //self.updateLayout()
                self.EventChatCollectionView.reloadData()
            }
        })
    }
}

extension NewContactPageViewController: UICollectionViewDataSource {
    //sets the number of items in collection view based on number of items in contacts array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bigGroupChatCollectionView {
            if contacts.count <= 3 {
                return contacts.count
            } else {
                return 4
            }
        } else if collectionView == self.littleGroupChatCollectionView {
            if contacts.count <= 4 {
                return 0
            } else {
                return contacts.count - 4
            }
        } else {
            return eventContacts.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //creates cell and sets nameLabel to the fullName item (in this case the name of the groupChat), then sets docuemntID to email item (in this case the groupChatDocumentID
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bigGroupChatCollectionView {
            let cell = bigGroupChatCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
            
            let sortedContacts = self.contacts.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let contact: Contact
            
            if collectionView == self.bigGroupChatCollectionView {
                cell.isMainFour = true
                
                contact = sortedContacts[indexPath.row]
            } else {
                cell.isMainFour = false
                
                contact = sortedContacts[indexPath.row + 4]
            }
            
            if contact.badgeCount == 0 {
                cell.hasUnreadMessages = false
            } else {
                cell.hasUnreadMessages = true
            }
            
            cell.contactName.text = contact.fullName
            cell.documentID = contact.email
            cell.members = contact.members
            cell.lastMessageLabel.text = contact.lastMessage
            
            let profileImageUrl = contact.profileImageUrl
            
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
                                print("Success downloading image", data)
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
        } else if collectionView == self.littleGroupChatCollectionView {
            let cell = littleGroupChatCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
            
            let sortedContacts = self.contacts.sorted(by: { $0.timeStamp > $1.timeStamp })
            
            let  contact = sortedContacts[indexPath.row + 4]
            
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
            
            let profileImageUrl = contact.profileImageUrl
            
            cell.profileImageUrl = profileImageUrl
            cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            
            if profileImageUrl == "default" || profileImageUrl == "" {
                return cell
            } else {
                if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                    cell.contactImageView.image = cachedImage as? UIImage
                } else if var imageDictionary = defaults.dictionary(forKey: "groupContactPictures") {
                    if let storedImageData = imageDictionary[profileImageUrl] {
                        let image = UIImage(data: storedImageData as! Data)
                        cell.contactImageView.image = image
                        let NSProfileImageUrl = profileImageUrl as NSString
                        self.imageCache.setObject(image!, forKey: NSProfileImageUrl)
                    } else {
                        Amplify.Storage.downloadData(key: profileImageUrl) { result in
                            switch result {
                            case .success(let data):
                                print("Success downloading image", data)
                                if let image = UIImage(data: data) {
                                    //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                    DispatchQueue.main.async {
                                        cell.contactImageView.image = image
                                        self.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                                        imageDictionary[profileImageUrl] = data
                                        self.defaults.setValue(imageDictionary, forKey: "groupContactPictures")
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
            let cell = EventChatCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
            
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
            cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            
            if profileImageUrl == "default" || profileImageUrl == "" {
                return cell
            } else {
                if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                    cell.contactImageView.image = cachedImage as? UIImage
                } else if var imageDictionary = defaults.dictionary(forKey: "groupContactPictures") {
                    if let storedImageData = imageDictionary[profileImageUrl] {
                        let image = UIImage(data: storedImageData as! Data)
                        cell.contactImageView.image = image
                        let NSProfileImageUrl = profileImageUrl as NSString
                        self.imageCache.setObject(image!, forKey: NSProfileImageUrl)
                    } else {
                        Amplify.Storage.downloadData(key: profileImageUrl) { result in
                            switch result {
                            case .success(let data):
                                print("Success downloading image", data)
                                if let image = UIImage(data: data) {
                                    //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                                    DispatchQueue.main.async {
                                        cell.contactImageView.image = image
                                        self.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                                        imageDictionary[profileImageUrl] = data
                                        self.defaults.setValue(imageDictionary, forKey: "groupContactPictures")
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

extension NewContactPageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //when item selected, pulls the document Id and groupchat title to give to class global variables to pass on to groupchatVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.bigGroupChatCollectionView {
            self.isEventChat = false
            
            let cell = bigGroupChatCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
            
            self.documentID = cell.documentID
            self.groupChatTitle = cell.contactName.text ?? ""
            self.groupChatImageUrl = cell.profileImageUrl ?? "default"
            
            let MembersRef = groupChatMessages.child(documentID).child("Members")
            
            MembersRef.observe(DataEventType.value, with: { (snapshot) in
                let postArray = snapshot.value as? [[String]] ?? [["FAILED"]]
                self.groupMembers = postArray
                self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
            })
        } else if collectionView == self.littleGroupChatCollectionView {
            self.isEventChat = false
            
            let cell = littleGroupChatCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
            
            self.documentID = cell.documentID
            self.groupChatTitle = cell.contactName.text ?? ""
            self.groupChatImageUrl = cell.profileImageUrl ?? "default"
            
            let MembersRef = groupChatMessages.child(documentID).child("Members")
            
            MembersRef.observe(DataEventType.value, with: { (snapshot) in
                let postArray = snapshot.value as? [[String]] ?? [["FAILED"]]
                self.groupMembers = postArray
                self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
            })
        } else {
            let cell = EventChatCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
            
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
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
     let cell = bigGroupChatCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
     
     if indexPath.section == 0 {
     let cellWidth = UIScreen.main.bounds.width/2 - 10
     let cellHeight = cellWidth/0.8244
     cell.isMainFour = true
     return CGSize(width: cellWidth, height: cellHeight) //235
     } else {
     let cellWidth = UIScreen.main.bounds.width/3 - 10
     let cellHeight = cellWidth/0.875
     cell.isMainFour = false
     return CGSize(width: cellWidth, height: cellHeight)
     }
     }*/
}



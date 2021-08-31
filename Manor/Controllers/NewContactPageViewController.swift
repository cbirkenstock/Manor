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

class NewContactPageViewController: UIViewController {
    
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var contactCollectionView: UICollectionView!
    @IBOutlet weak var createConversationButton: UIBarButtonItem!
    
    //--//
    
    let db = Firestore.firestore()
    var ref: DocumentReference?
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    let groupChatMessages = Database.database().reference().child("GroupChatMessages")
    let chatViewController = ChatViewController()
    
    let dropDown = DropDown()
    let flowLayout = UICollectionViewFlowLayout()
    
    var user: User! = Firebase.Auth.auth().currentUser
    var userFullName: String = ""
    var documentID: String = ""
    
    var contacts: [Contact] = []
    var groupChats: [String] = []
    var groupChatTitle: String = ""
    var groupMembers: [[String]] = []
    var groupChatImageUrl: String = ""
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    //--//
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeGroupChatTitleBold"), object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        self.contactCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "testTwoCell")
        
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
        
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        
        //sets size, scroll direction, etc. of contacts in collection view
        //let cellWidth = UIScreen.main.bounds.width/2 - 10
        //let cellHeight = cellWidth/0.8244
        //flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight) //235
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5.0
        contactCollectionView.collectionViewLayout = flowLayout
        
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
    
    //passes documentID and groupChatTitle to groupChatView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is GroupChatViewController {
            let vc = segue.destination as! GroupChatViewController
            vc.documentID = self.documentID
            vc.groupChatTitle = self.groupChatTitle
            vc.groupMembers = self.groupMembers
            vc.groupChatImageUrl = self.groupChatImageUrl
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
                if let groupChatTitle = value.object(forKey: "title") as? String, let groupChatDocumentID = value.object(forKey: "documentID") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String, let lastMessage = value.object(forKey: "lastMessage") as? String{
                    
                    let timeStamp = commaTimeStamp.replacingOccurrences(of: ",", with: ".")
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    let badgeCount = Int(stringBadgeCount)
                    
                    let profileImageUrl = value.object(forKey: "profileImageUrl") as? String ?? "default"
                    
                    self.groupChatImageUrl = profileImageUrl
                    
                    
                    let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: lastMessage, badgeCount: badgeCount!, profileImageUrl: profileImageUrl)
                    
                    self.contacts.append(groupChatContact)
                }
            }
            DispatchQueue.main.async {
                self.contactCollectionView.reloadData()
            }
        })
        
        /*db.collection("GroupChatsByUser").document("\(String(describing: self.user!.email!))").collection("Chats").order(by: "timeStamp").addSnapshotListener { (querySnapshot, err) in
         if let err = err {
         print("Error getting documents: \(err)")
         } else {
         if (querySnapshot!.documents.isEmpty) {
         print("No documents in GroupSnapshot")
         } else {
         for document in querySnapshot!.documents {
         if let groupChatTitle = document.data()["title"], let groupChatDocumentID = document.data()["documentID"], let timeStamp = document.data()["timeStamp"]{
         let groupChatContact = Contact(email: groupChatDocumentID as! String, fullName: groupChatTitle as! String, timeStamp: timeStamp as! Double)
         self.contacts.append(groupChatContact)
         DispatchQueue.main.async {
         self.contactCollectionView.reloadData()
         }
         }
         }
         }
         }
         }*/
    }
}

extension NewContactPageViewController: UICollectionViewDataSource {
    //sets the number of items in collection view based on number of items in contacts array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if contacts.count <= 3 {
                return contacts.count
            } else {
                return 4
            }
        } else {
            if contacts.count <= 4 {
                return 0
            } else {
                return contacts.count - 4
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    //creates cell and sets nameLabel to the fullName item (in this case the name of the groupChat), then sets docuemntID to email item (in this case the groupChatDocumentID
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
        
        let sortedContacts = self.contacts.sorted(by: { $0.timeStamp > $1.timeStamp })
        
        let contact: Contact
        
        if indexPath.section == 0 {
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
        }  else if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
            cell.contactImageView.image = cachedImage as? UIImage
        } else {
            Amplify.Storage.downloadData(key: profileImageUrl) { result in
                switch result {
                case .success(let data):
                    print("Success downloading image", data)
                    if let image = UIImage(data: data) {
                        //let imageHeight = CGFloat(image.size.height/image.size.width * 300)
                        DispatchQueue.main.async {
                            self.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                            cell.contactImageView.image = image
                        }
                    }
                case .failure(let error):
                    print("failure downloading image", error)
                }
            }
            DispatchQueue.global().async { [weak self] in
                let URL = URL(string: profileImageUrl)
                if let data = try? Data(contentsOf: URL!) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self!.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                            cell.contactImageView.image = image
                        }
                    }
                }
            }
        }
        return cell
    }
}

extension NewContactPageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //when item selected, pulls the document Id and groupchat title to give to class global variables to pass on to groupchatVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = contactCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
        
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
    }
}



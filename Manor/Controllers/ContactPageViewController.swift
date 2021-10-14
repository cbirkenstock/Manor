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

class ContactPageViewController: UIViewController {
    
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var contactCollectionView: UICollectionView!
    @IBOutlet weak var createConversationButton: UIBarButtonItem!
    
    //--//
    
    let db = Firestore.firestore()
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    let usersRef = Database.database().reference().child("users")
    let chatViewcontroller = ChatViewController()
    var ref: DocumentReference? = nil
    var user: User! = Firebase.Auth.auth().currentUser
    var otherUserFullName = ""
    var otherUserEmail: String = ""
    var userFullName: String = ""
    var contacts: [Contact] = []
    var groupChats: [String] = []
    let dropDown = DropDown()
    let flowLayout = UICollectionViewFlowLayout()
    var groupChatImageUrl: String = ""
    
    let imageCache = NSCache<NSString, AnyObject>()
    let defaults = UserDefaults.standard
    
    //--//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let view2 = UIView()
        //self.view.addSubview(view2)
        let navBarHeight = navigationController?.navigationBar.frame.height
        //view2.frame = CGRect(x: 100, y: 100, width: (navBarHeight ?? 30) - 10, height: (navBarHeight ?? 30) - 10)
        view2.frame.size.height = (navBarHeight ?? 30)
        view2.frame.size.width = (navBarHeight ?? 30)
        view2.layer.cornerRadius = ((navBarHeight ?? 30))/2
        view2.backgroundColor = .red
        
        let imageView: UIImageView = UIImageView()
        view2.addSubview(imageView)
        imageView.frame.size.height = (navBarHeight ?? 30)
        imageView.frame.size.width = (navBarHeight ?? 30)
        imageView.layer.cornerRadius = ((navBarHeight ?? 30))/2
        imageView.backgroundColor = .blue
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .small)
        imageView.image = UIImage(systemName: "person", withConfiguration: config)
        imageView.clipsToBounds = true
        
        
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view2.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view2.trailingAnchor, constant: 0),
        ]
        
        //NSLayoutConstraint.activate(constraints)
        
        

        
        //let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .default)

        //let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)*/
        
        /*if #available(iOS 14.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium, scale: .large)
            let image = UIImage(systemName: "person", withConfiguration: config)
            let barButton = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
            self.navigationItem.setLeftBarButton(barButton, animated: true)
        }*/
        
         //
        
        Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
        
        self.contactCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        
        //shows navigation bar
        //navigationController?.setNavigationBarHidden(false, animated: true)
         
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "warmBlack")
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
        loadContacts()
    }
    
    //gives chat view controller otherUserFullName, otherUserEmail, and userFullName
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChatViewController {
            let vc = segue.destination as! ChatViewController
            vc.otherUserFullName = self.otherUserFullName
            vc.otherUserEmail = self.otherUserEmail
            vc.userFullName = self.userFullName
            
            if(user.email! < otherUserEmail ) {
                let chatTitle = "\(self.user!.email!) + \(otherUserEmail)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            } else {
                let chatTitle = "\(otherUserEmail) + \(self.user!.email!)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController else { return }
        let navBarHeight = navigationController.navigationBar.frame.height
        //let threshold: CGFloat = 20
        //let alpha = (scrollView.contentOffset.y + navBarHeight + threshold) / threshold
        let alpha: CGFloat = (scrollView.contentOffset.y + 88)/100
        navigationController.navigationBar.subviews.first?.alpha = alpha
    }
    
    @IBAction func CreateNewMessagePressed(_ sender: Any) {
        dropDown.show()
    }
    
    //listend loads and continues to listen for new objects under chatsByUser.userEmail.Chats
    //has otherUserEmail, otherUserFullName, and timeStamp as empty to be filled in with values from this ref
    //creates contact value and appends to contacts array and reloads collection view data
    func loadContacts() {
        let userEmail = self.user!.email!
        let commaEmail = userEmail.replacingOccurrences(of: ".", with: ",")
        
        let userChatsRef = chatsByUserRef.child(commaEmail).child("Chats")
        
        userChatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            var otherUserEmail: String = ""
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
                    
                    
                    
                    let userContact = Contact(email: otherUserEmail, fullName: otherUserFullName, timeStamp: timeStamp, lastMessage: lastMessage, badgeCount: badgeCount!, profileImageUrl: profileImageUrl)
                    
                    self.contacts.append(userContact)
                    for contact in self.contacts {
                        print(contact.profileImageUrl)
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.contactCollectionView.reloadData()
                }
            }
        })
        
        let chatsRef = groupChatsByUserRef.child(commaEmail).child("Chats")
        
        chatsRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for value in postDict.values {
                if let groupChatTitle = value.object(forKey: "title") as? String, let groupChatDocumentID = value.object(forKey: "documentID") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    
                    let timeStamp = commaTimeStamp.replacingOccurrences(of: ",", with: ".")
                    
                    let stringBadgeCount = value.object(forKey: "badgeCount") as? String ?? "0"
                    let badgeCount = Int(stringBadgeCount)
                    
                    let lastMessage = value.object(forKey: "lastMessage") as? String ?? ""
                    
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeDMTitleBold"), object: nil)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension ContactPageViewController: UICollectionViewDataSource {
    //sets count for how many objects there will be in collection view based on how many obejcts are in contacts array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    //creates each cell as ContactCollectionViewCell, sorts the contacts array by timestamp, and then sets the nameLabel of the cell to fullName and the documentID of cell to email
    //documentID is set to email just to have the cell hold that info for when it is selected so this view controller can pass the otherUserEmail to the chatviewcontroller
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
        let profileImageUrl = sortedContacts[indexPath.row].profileImageUrl
        
        cell.profileImageUrl = profileImageUrl
        cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
        
        if profileImageUrl == "default" || profileImageUrl == "" {
            print("true")
            return cell
        } else {
            if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                print("there is cached image")
                cell.contactImageView.image = cachedImage as? UIImage
            } else if var imageDictionary = defaults.dictionary(forKey: "ContactPictures") {
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
                                    self.defaults.setValue(imageDictionary, forKey: "ContactPictures")
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

//once the ContactCollectionViewCell is selected, its nameLabel and documentID properties are used to assign to otherUserFullName and otherUserEmail to be passed on to other VC
extension ContactPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = contactCollectionView.cellForItem(at: indexPath) as? TestCollectionViewCell {
            
            self.otherUserFullName = cell.contactName.text ?? ""
            self.otherUserEmail = cell.documentID
        }
        
        performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
    }
}



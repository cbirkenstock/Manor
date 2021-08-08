//
//  NewContactPageViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/25/21.
//

import UIKit
import Firebase
import DropDown

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
    var groupMembers: [String] = []
    
    //--//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        
        title = "Messages"
        
        //shows navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: false)
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController!.navigationBar.tintColor = UIColor(named: K.BrandColors.purple);
        
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        
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
        }
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
                   
                    
                    if let stringBadgeCount = value.object(forKey: "badgeCount") as? String {
                        let badgeCount = Int(stringBadgeCount)
                        let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: lastMessage, badgeCount: badgeCount!)
                        self.contacts.append(groupChatContact)
                    } else {
                        let groupChatContact = Contact(email: groupChatDocumentID , fullName: groupChatTitle , timeStamp: Double(timeStamp)!, lastMessage: lastMessage)
                        self.contacts.append(groupChatContact)
                    }
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
        return contacts.count
    }
    //creates cell and sets nameLabel to the fullName item (in this case the name of the groupChat), then sets docuemntID to email item (in this case the groupChatDocumentID
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCollectionViewCell
        
        let sortedContacts = self.contacts.sorted(by: { $0.timeStamp > $1.timeStamp })
        
        if sortedContacts[indexPath.row].badgeCount == 0 {
            cell.hasUnreadMessages = false
        } else {
            cell.hasUnreadMessages = true
        }
        
        cell.contactName.text = sortedContacts[indexPath.row].fullName
        cell.documentID = sortedContacts[indexPath.row].email
        cell.members = sortedContacts[indexPath.row].members
        cell.lastMessageLabel.text = sortedContacts[indexPath.row].lastMessage
        
        return cell
    }
}

extension NewContactPageViewController: UICollectionViewDelegate {
    //when item selected, pulls the document Id and groupchat title to give to class global variables to pass on to groupchatVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = contactCollectionView.cellForItem(at: indexPath) as! TestCollectionViewCell
        
        self.documentID = cell.documentID
        self.groupChatTitle = cell.contactName.text ?? ""
        
        let MembersRef = groupChatMessages.child(documentID).child("Members")
        
        MembersRef.observe(DataEventType.value, with: { (snapshot) in
            let postArray = snapshot.value as? [String] ?? ["FAILED"]
            self.groupMembers = postArray
            self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
        })
                

    }
}



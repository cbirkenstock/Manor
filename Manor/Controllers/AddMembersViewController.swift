//
//  addMembersViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/15/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins



class AddMembersViewController: UIViewController {
    
    @IBOutlet weak var searchNamesBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chosenNamesContainer: UIView!
    @IBOutlet weak var chosenNamesContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchNamesCollectionView: UICollectionView!
    @IBOutlet weak var chosenNamesCollectionView: UICollectionView!
    
    @IBOutlet weak var chosenCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contactTextField: UITextField!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    //--//
    
    
    //let db = Firestore.firestore()
    let userRef = Database.database().reference().child("users")
    var groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    let eventChatsByUserRef =
        Database.database().reference().child("EventChatsByUser")
    let eventChatMessagesRef = Database.database().reference().child("EventChatMessages")
    var user: User! = Firebase.Auth.auth().currentUser
    var ref: DocumentReference? = nil
    
    var searchNames: [Contact] = []
    var chosenNames: [Contact] = []
    var groupMembers: [[String]] = []
    //var otherUserFullName: String = ""
    //var otherUserEmail: String = ""
    var userFullName: String = ""
    var documentID: String = ""
    var groupChatTitle: String = ""
    var lastMessage: String = ""
    var isEventChat: Bool! = false
    
    let searchNamesflowLayout = UICollectionViewFlowLayout()
    let chosenflowLayout = UICollectionViewFlowLayout()
    
    let underline: UIView = {
        let underline = UIView()
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor(named: K.BrandColors.purple)
        return underline
    }()
    
    
    
    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(underline)
        let underlineConstraints = [
            underline.topAnchor.constraint(equalTo: contactTextField.bottomAnchor, constant: 0),
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: self.contactTextField.leadingAnchor, constant: 0),
            underline.trailingAnchor.constraint(equalTo: self.contactTextField.trailingAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(underlineConstraints)

        let lastMessageRef = groupChatMessagesRef.child(documentID).child("lastMessage")
        
        lastMessageRef.observe(DataEventType.value, with: { (snapshot) in
            let lastMessage = snapshot.value as? String ?? ""
            self.lastMessage = lastMessage
        })
            
        self.searchNamesCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "contactCollectionViewCell")
        self.chosenNamesCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "contactCollectionViewCell")
            
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationController?.navigationBar.barTintColor = .black//UIColor(named: K.BrandColors.backgroundBlack)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController!.navigationBar.tintColor = UIColor(named: K.BrandColors.purple);
        
        //set delegates
        searchNamesCollectionView.dataSource = self
        searchNamesCollectionView.delegate = self
        chosenNamesCollectionView.dataSource = self
        chosenNamesCollectionView.delegate = self
        
        /*//view layout creation
        contactBarView.layer.cornerRadius = contactBarView.bounds.height/2
        contactBarView.layer.borderWidth = 3
        contactBarView.layer.borderColor = UIColor(named: "BrandPurpleColor")?.cgColor*/
        
        /*groupTitleView.layer.cornerRadius = contactBarView.bounds.height/2
        groupTitleView.layer.borderWidth = 3
        groupTitleView.layer.borderColor = UIColor(named: "BrandPurpleColor")?.cgColor*/
        
        //automatically adds user to groupMembers since they are the one creating the chat
        //groupMembers.append(user.email!)
        
        //before there are any contacts added, the height is zero so it doesn't show
        chosenCollectionViewHeight.constant = 0
        chosenNamesContainerHeight.constant = 0
        
        
        //collection view layout for searched names
        //set up collection view for contact cells
        let cellWidth = UIScreen.main.bounds.width/3 - 10
        let cellHeight = cellWidth/0.7
        
        searchNamesflowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight) //235
        searchNamesflowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        searchNamesflowLayout.scrollDirection = .vertical
        searchNamesflowLayout.minimumInteritemSpacing = 5.0
        searchNamesCollectionView.collectionViewLayout = searchNamesflowLayout
        
        
        //collection view layout for chosen names
        chosenflowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/5 - 10, height: 90)
        chosenflowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        chosenflowLayout.scrollDirection = .horizontal
        chosenflowLayout.minimumInteritemSpacing = 0.0
        chosenNamesCollectionView.collectionViewLayout = chosenflowLayout
    }
    
    //everytime a letter is entered into the search bar it reloads the search names
    @IBAction func membersEditingChanged(_ sender: Any) {
        loadSearchNames()
    }
    
    @IBAction func membersEditingBegan(_ sender: Any) {
        self.contactTextField.text = ""
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //pushMessageButton.isEnabled = true
        //pushMessageButton.tintColor = UIColor(named: K.BrandColors.red)
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        
        self.searchNamesBottomConstraint.constant = keyboardFrame
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        self.searchNamesBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    //same as algorithm in NewConversationViewController except also checks if name is already in chosen names so doesn't list name that you've already added
    func loadSearchNames() {
        let searchName = contactTextField.text
        
        //goes through whole list of users on app
        userRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.searchNames = []
            for value in postDict.values {
                //creates contact icon for all the users
                if let userFirstName = value.object(forKey: "firstName") as? String, let userLastName = value.object(forKey: "lastName") as? String, let userEmail = value.object(forKey: "email") as? String {
                    let userFullName = "\(userFirstName) \(userLastName)"
                    let userProfileImageUrl = (value.object(forKey: "profileImageUrl") as? String) ?? "default"
                    let userContact: Contact = Contact(email: userEmail, fullName: userFullName, profileImageUrl: userProfileImageUrl)
                    //this loop just checks to see if all the letters of someone's name matches the searched name
                    if let i = searchName?.count {
                        var letterPos = 0
                        while letterPos < i {
                            //removes names that are too short (letters typed into search already longer than the name)
                            if (userFirstName.count == letterPos ) {
                                self.searchNames = self.searchNames.filter({
                                    return $0 != userContact
                                })
                                break
                            }
                            //gets index of letter based on letterPos in both searched name and first name of current contact
                            let searchNameLetterIndex = searchName!.index(searchName!.startIndex, offsetBy: letterPos)
                            let firstNameLetterIndex = userFirstName.index(userFirstName.startIndex, offsetBy: letterPos)
                            //if the two letters are the same, then adds name to searchNames (unless already there)
                            if (letterPos == 0) {
                                if (searchName![searchNameLetterIndex].lowercased() == userFirstName[firstNameLetterIndex].lowercased()) {
                                    if (!self.chosenNames.contains(userContact) && !self.groupMembers.contains([userContact.fullName, userContact.email])) {
                                        self.searchNames.append(userContact)
                                        DispatchQueue.main.async {
                                            self.searchNamesCollectionView.reloadData()
                                        }
                                    }
                                }
                                //since after the first letter, the possible names will only decrease, this checks to see if the next letters are the same, if they aren't the name is removed from the array
                            } else {
                                if (userFirstName.count == letterPos || searchName![searchNameLetterIndex].lowercased() != userFirstName[firstNameLetterIndex].lowercased()) {
                                    self.searchNames = self.searchNames.filter({
                                        return $0 != userContact
                                    })
                                }
                            }
                            letterPos += 1
                        }
                        DispatchQueue.main.async {
                            self.searchNamesCollectionView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func addBarButtonPressed(_ sender: Any) {
        let timestamp = Date().timeIntervalSince1970
        let stringTimestamp = "\(timestamp)"
        let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
        
        let membersRef = groupChatMessagesRef.child(documentID).child("Members")
        
        if self.isEventChat {
            let membersRef = eventChatMessagesRef.child(documentID).child("Members")
            for contact in chosenNames {
                let commaEmail = contact.email.replacingOccurrences(of: ".", with: ",")
                self.eventChatsByUserRef.child(commaEmail).child("Chats").child(self.documentID).setValue([
                    "title": groupChatTitle,
                    "documentID": documentID,
                    "lastMessage": self.lastMessage,
                    "timeStamp": commaTimestamp
                ])
            }
            
            membersRef.setValue(self.groupMembers)
        } else {
            let membersRef = groupChatMessagesRef.child(documentID).child("Members")
            for contact in chosenNames {
                let commaEmail = contact.email.replacingOccurrences(of: ".", with: ",")
                self.groupChatsByUserRef.child(commaEmail).child("Chats").child(self.documentID).setValue([
                    "title": groupChatTitle,
                    "documentID": documentID,
                    "lastMessage": self.lastMessage,
                    "timeStamp": commaTimestamp
                ])
            }
            membersRef.setValue(self.groupMembers)
        }
    }
}

extension AddMembersViewController: UICollectionViewDataSource {
    // checks to see which collection view we are dealing with and then sets size based on appropriate array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.searchNamesCollectionView {
            return searchNames.count
        } else {
            return chosenNames.count
        }
        
    }
    
    //sets cell's nameLabel to name of contact and the document ID to their email, if it's the chosen collection view then only does names
    /*func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchNamesCollectionView {
            let cell = searchNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! TestTwoCollectionViewCell
            
            cell.nameLabel.text = searchNames[indexPath.row].fullName
            cell.documentID = searchNames[indexPath.row].email
            
            return cell
            
        } else {
            
            let cell = chosenNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChosenNameCell
            
            if (chosenNames.count >= 1) {
                cell.nameLabel.text = chosenNames[indexPath.row].fullName
            }
            
            return cell
            
        }
    }*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchNamesCollectionView {
            let cell = searchNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! TestTwoCollectionViewCell
            
            let fullName = searchNames[indexPath.row].fullName
            
            let fullNameArray = fullName.split(separator: " ")
            
            let firstName = fullNameArray[0]
            let lastName = fullNameArray[1]
            
            cell.isBig = true
            cell.contactFirstName.text = String(firstName)
            cell.contactLastName.text = String(lastName)
            cell.documentID = searchNames[indexPath.row].email
            
            //cell.isSearchName = true
            
            let profileImageUrl = searchNames[indexPath.row].profileImageUrl
            
            //cell = profileImageUrl
            cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            
            if profileImageUrl == "default" {
                return cell
            /*}  else if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                cell.contactImageView.image = cachedImage as? UIImage*/
            } else {
                Amplify.Storage.downloadData(key: profileImageUrl) { result in
                    switch result {
                    case .success(let data):
                        print("Success downloading image", data)
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.contactImageView.image = image
                            }
                        }
                    case .failure(let error):
                        print("failure downloading image", error)
                    }
                }
            }
            return cell
        } else {
            let cell = chosenNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! TestTwoCollectionViewCell
            
            let fullName = chosenNames[indexPath.row].fullName
            
            let fullNameArray = fullName.split(separator: " ")
            
            let firstName = fullNameArray[0]
            //let lastName = fullNameArray[1]
            
            cell.isBig = false
            cell.contactFirstName.text = String(firstName)
            //cell.contactLastName.text = String(lastName)
            cell.documentID = chosenNames[indexPath.row].email
            
            //cell.isSearchName = true
            let profileImageUrl = chosenNames[indexPath.row].profileImageUrl
            
            //cell.profileImageUrl = profileImageUrl
            cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            
            if let image = chosenNames[indexPath.row].image {
                cell.contactImageView.image = image
            } else if profileImageUrl == "default" {
                return cell
            /*}  else if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
                cell.contactImageView.image = cachedImage as? UIImage*/
            } else {
                Amplify.Storage.downloadData(key: profileImageUrl) { result in
                    switch result {
                    case .success(let data):
                        print("Success downloading image", data)
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.contactImageView.image = image
                            }
                        }
                    case .failure(let error):
                        print("failure downloading image", error)
                    }
                }
            }
            return cell
        }
        

    }
}

extension AddMembersViewController: UICollectionViewDelegate {
    //when selecting contacts, they are added to the chosenNames array and the create groupchat button is now shown
    //when clicking a contact from the chosen collection view, it removes the contact from the array and the groupMembers array
    //also resets height of view showing chosen contacts so that is is exposed when there is at least one contact
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.searchNamesCollectionView {
            let cell = searchNamesCollectionView.cellForItem(at: indexPath) as! TestTwoCollectionViewCell
            
            let userFullName = "\(cell.contactFirstName.text ?? "error") \(cell.contactLastName.text ?? "error")"
            let userFirstName = cell.contactFirstName.text ?? ""
            let userEmail = cell.documentID
            let profileImage = cell.contactImageView.image
            
            let userContact = Contact(email: userEmail, fullName: userFirstName, image: profileImage)
            if (!chosenNames.contains(userContact)) {
                chosenNames.append(userContact)
                if (!groupMembers.contains([userFullName, userContact.email])) {
                    groupMembers.append([userFullName, userContact.email])
                }
                addBarButton.tintColor = UIColor(named: K.BrandColors.purple)
                DispatchQueue.main.async {
                    self.chosenNamesCollectionView.reloadData()
                    self.loadSearchNames()
                    let indexPath = IndexPath(row: self.chosenNames.count - 1, section: 0)
                    self.chosenNamesCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
                }
            }
        } else {
            chosenNames.remove(at: indexPath.row)
            groupMembers.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.chosenNamesCollectionView.reloadData()
                self.loadSearchNames()
            }
        }
        if chosenNames.count == 0 {
            chosenCollectionViewHeight.constant = 0
            chosenNamesContainerHeight.constant = 0
        } else {
            chosenCollectionViewHeight.constant = 92
            chosenNamesContainerHeight.constant = 98
        }
    }
}

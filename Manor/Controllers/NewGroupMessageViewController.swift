//
//  NewConversationViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/22/21.
//

import UIKit
import Firebase

class NewGroupMessageViewController: UIViewController {
    
    
    @IBOutlet weak var chosenNamesContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var chosenNamesContainer: UIView!
    @IBOutlet weak var searchNamesCollectionView: UICollectionView!
    @IBOutlet weak var chosenCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chosenCollectionView: UICollectionView!
    @IBOutlet weak var groupTitleView: UIView!
    @IBOutlet weak var contactBarView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var createBarButton: UIBarButtonItem!
    
    //--//
    
    let db = Firestore.firestore()
    let userRef = Database.database().reference().child("users")
    var groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    var user: User! = Firebase.Auth.auth().currentUser
    var ref: DocumentReference? = nil
    
    var searchNames: [Contact] = []
    var chosenNames: [Contact] = []
    var groupMembers: [[String]] = []
    var otherUserFullName: String = ""
    var otherUserEmail: String = ""
    var userFullName: String = ""
    var documentID: String = "\(Int.random(in: 1...10000000000000))"
    
    let searchNamesflowLayout = UICollectionViewFlowLayout()
    let chosenflowLayout = UICollectionViewFlowLayout()
    
    let usersRef = Database.database().reference().child("users")
    
    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commaEmail = user.email!.replacingOccurrences(of: ".", with: ",")
        
        usersRef.child(commaEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let firstName = value["firstName"] as? String ?? ""
                let lastName = value["lastName"] as? String ?? ""
                self.userFullName = "\(firstName) \(lastName)"
                self.groupMembers.append([self.userFullName, self.user.email!])
            } else {
                print("No Value")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        chosenNamesContainer.layer.cornerRadius = 10
        
        /*contactTextField.layer.borderColor = UIColor.red.cgColor
        contactTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.red.cgColor
        titleTextField.layer.borderWidth = 1*/
        
        setUpLine(anchor: contactTextField.topAnchor, constant: -1)
        setUpLine(anchor: contactTextField.bottomAnchor, constant: 1)
        
        //navigationController?.navigationBar.barTintColor = .black//UIColor(named: K.BrandColors.backgroundBlack)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        //self.navigationController!.navigationBar.tintColor = UIColor(named: K.BrandColors.purple);
        
        //set delegates
        searchNamesCollectionView.dataSource = self
        searchNamesCollectionView.delegate = self
        chosenCollectionView.dataSource = self
        chosenCollectionView.delegate = self
        
        //view layout creation
        /*contactBarView.layer.cornerRadius = contactBarView.bounds.height/2
        contactBarView.layer.borderWidth = 3
        contactBarView.layer.borderColor = UIColor(named: "BrandPurpleColor")?.cgColor
        
        groupTitleView.layer.cornerRadius = contactBarView.bounds.height/2
        groupTitleView.layer.borderWidth = 3
        groupTitleView.layer.borderColor = UIColor(named: "BrandPurpleColor")?.cgColor*/
        
        //automatically adds user to groupMembers since they are the one creating the chat

        /*let commaEmail = user.email!.replacingOccurrences(of: ".", with: ",")
        userRef.child(commaEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let firstName = value["firstName"] as! String
                let lastName = value["lastName"] as! String
                self.userFullName = "\(firstName) \(lastName)"
                
                let userContact = Contact(email: commaEmail, fullName: self.userFullName)
                self.groupMembers.append(userContact)
            }
        })*/
        
        //before there are any contacts added, the height is zero so it doesn't show
        chosenCollectionViewHeight.constant = 0
        chosenNamesContainerHeight.constant = 0
        
        
        //collection view layout for searched names
        let cellWidth = UIScreen.main.bounds.width/3 - 15
        let cellHeight = cellWidth/0.8244
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
        chosenCollectionView.collectionViewLayout = chosenflowLayout
    }
    
    //send over appropriate information to groupchat view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GroupChatViewController {
            let vc = segue.destination as! GroupChatViewController
            vc.groupMembers = groupMembers
            vc.groupChatTitle = titleTextField.text ?? ""
            vc.documentID = documentID
            
            
        }
    }
    
    
    func setUpLine(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        let view = UIView()
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: K.BrandColors.purple)
        
        let view1Constraints = [
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            view.topAnchor.constraint(equalTo: anchor, constant: constant)
        ]
        
        NSLayoutConstraint.activate(view1Constraints)
    }
    
    //everytime a letter is entered into the search bar it reloads the search names
    
    @IBAction func contactTextFieldEditingChanged(_ sender: Any) {
        loadSearchNames()
    }
    

    @IBAction func chatTitleEditingBegan(_ sender: Any) {
        self.titleTextField.text = ""
    }
    
    
    @IBAction func memberEditingBegan(_ sender: Any) {
        self.contactTextField.text = ""
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
                let userFirstName = (value.object(forKey: "firstName") as? String) ?? ""
                let userLastName = (value.object(forKey: "lastName") as? String) ?? ""
                let userFullName = "\(userFirstName) \(userLastName)"
                let userEmail = value.object(forKey: "email") as? String ?? ""
                let userContact: Contact = Contact(email: userEmail, fullName: userFullName)
                //this loop just checks to see if all the letters of someone's name matches the searched name
                if let i = searchName?.count {
                    var letterPos = 0
                    while letterPos < i {
                        // checks if name is already in chosenNames
                        if (self.chosenNames.contains(userContact)) {
                            break
                        }
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
                                if (!self.searchNames.contains(userContact)) {
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
        })
    }
    
    
    /*func loadSearchNames() {
     let searchName = contactTextField.text
     
     db.collection("users").order(by: "firstName").addSnapshotListener { (QuerySnapshot, err) in
     if let err = err {
     print ("Error obtaining users, \(err)")
     } else {
     self.searchNames = []
     for document in QuerySnapshot!.documents {
     let userFirstName = document.data()["firstName"] as! String
     let userLastName = document.data()["lastName"] as! String
     let userFullName = "\(userFirstName) \(userLastName)"
     let userEmail = document.data()["email"] as! String
     let userContact: Contact = Contact(email: userEmail, fullName: userFullName)
     if let i = searchName?.count {
     var letterPos = 0
     while letterPos < i {
     if (self.chosenNames.contains(userContact)) {
     break
     }
     if (userFirstName.count == letterPos ) {
     self.searchNames = self.searchNames.filter({
     return $0 != userContact
     })
     break
     }
     let searchNameLetterIndex = searchName!.index(searchName!.startIndex, offsetBy: letterPos)
     let firstNameLetterIndex = userFirstName.index(userFirstName.startIndex, offsetBy: letterPos)
     if (letterPos == 0) {
     if (searchName![searchNameLetterIndex].lowercased() == userFirstName[firstNameLetterIndex].lowercased()) {
     if (!self.searchNames.contains(userContact)) {
     self.searchNames.append(userContact)
     DispatchQueue.main.async {
     self.searchNamesCollectionView.reloadData()
     }
     }
     }
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
     }*/
    
    @IBAction func createBarButtonPressed(_ sender: Any) {
        let timestamp = Date().timeIntervalSince1970
        let stringTimestamp = "\(timestamp)"
        let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
        
        self.groupChatMessagesRef.child(documentID).setValue([
            "title": titleTextField?.text ?? "",
            "messageCreator": self.user!.email!,
            "timeStamp": commaTimestamp,
            "Members": self.groupMembers,
            "lastMessage": "",
        ])
        
        self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
        
        
        /*db.collection("GroupChatMessages").document().setData([
         "title": titleTextField?.text ?? "",
         "messageCreator": self.user!.email!,
         "timeStamp": timestamp,
         "Members": groupMembers
         ])
         
         let groupChatsRef = self.db.collection("GroupChatMessages")
         
         
         groupChatsRef.order(by: "timeStamp", descending: true).getDocuments { querySnapshot, err in
         if let err = err {
         print("Error getting documents: \(err)")
         } else {
         for document in querySnapshot!.documents {
         if (document.data()["title"] as! String == self.titleTextField.text ?? "") {
         self.db.collection("GroupChatMessages").document(document.documentID).setData([
         "documentID": document.documentID
         ])
         self.documentID = document.documentID
         self.performSegue(withIdentifier: K.Segues.GroupChatSegue, sender: self)
         break
         } else {
         }
         }
         }
         }*/
    }
    
}


extension NewGroupMessageViewController: UICollectionViewDataSource {
    // checks to see which collection view we are dealing with and then sets size based on appropriate array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.searchNamesCollectionView {
            return searchNames.count
        } else {
            return chosenNames.count
        }
        
    }
    
    //sets cell's nameLabel to name of contact and the document ID to their email, if it's the chosen collection view then only does names
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchNamesCollectionView {
            let cell = searchNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
            
            cell.nameLabel.text = searchNames[indexPath.row].fullName
            cell.documentID = searchNames[indexPath.row].email
            
            return cell
            
        } else {
            
            let cell = chosenCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChosenNameCell
            
            if (chosenNames.count >= 1) {
                cell.nameLabel.text = chosenNames[indexPath.row].fullName
            }
            
            return cell
            
        }
    }
}

extension NewGroupMessageViewController: UICollectionViewDelegate {
    //when selecting contacts, they are added to the chosenNames array and the create groupchat button is now shown
    //when clicking a contact from the chosen collection view, it removes the contact from the array and the groupMembers array
    //also resets height of view showing chosen contacts so that is is exposed when there is at least one contact
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.searchNamesCollectionView {
            let cell = searchNamesCollectionView.cellForItem(at: indexPath) as! ContactCollectionViewCell
            
            let userFullName = cell.nameLabel.text?.components(separatedBy: " ")
            let userFirstName = userFullName![0]
            let userEmail = cell.documentID
            let userContact = Contact(email: userEmail, fullName: userFirstName)
            if (!chosenNames.contains(userContact)) {
                chosenNames.append(userContact)
                if (!groupMembers.contains([cell.nameLabel.text!, userContact.email])) {
                    groupMembers.append([cell.nameLabel.text!, userContact.email])
                }
                createBarButton.tintColor = UIColor(named: K.BrandColors.purple)
                self.contactTextField.text = ""
                self.loadSearchNames()
                DispatchQueue.main.async {
                    self.chosenCollectionView.reloadData()
                }
            }
        } else {
            chosenNames.remove(at: indexPath.row)
            groupMembers.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.chosenCollectionView.reloadData()
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


/*extension NewGroupMessageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return chosenNames.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
 let cell = chosenCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChosenNameCell
 
 if (chosenNames.count >= 1) {
 cell.nameLabel.text = chosenNames[indexPath.row].fullName
 }
 
 return cell
 }
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 chosenNames.remove(at: indexPath.row)
 DispatchQueue.main.async {
 self.chosenCollectionView.reloadData()
 }
 }
 }*/









//
//  NewConversationViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/22/21.
//

import UIKit
import Firebase

class NewConversationViewController: UIViewController {
    
    @IBOutlet weak var searchNamesCollectionView: UICollectionView!
    @IBOutlet weak var contactBarView: UIView!
    @IBOutlet weak var contactTextField: UITextField!
    
    //--//
    
    let db = Firestore.firestore()
    let userRef = Database.database().reference().child("users")
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    var ref: DocumentReference? = nil
    var user: User! = Firebase.Auth.auth().currentUser
    
    var searchNames: [Contact] = []
    var otherUserFullName: String = ""
    var otherUserEmail: String = ""
    var userFullName: String = ""
    
    let flowLayout = UICollectionViewFlowLayout()
    var documentName: String = ""
    
    var profileImageUrl: String = ""

    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchNamesCollectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "contactCollectionViewCell")
        
        navigationController?.navigationBar.barTintColor = .black//UIColor(named: K.BrandColors.backgroundBlack)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController!.navigationBar.tintColor = UIColor(named: K.BrandColors.purple);
        
        //setup delegates
        searchNamesCollectionView.dataSource = self
        searchNamesCollectionView.delegate = self
        
        
        //set up collection view for contact cells
        let cellWidth = UIScreen.main.bounds.width/3 - 15
        let cellHeight = cellWidth/0.8244
        
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight) //235
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5.0
        searchNamesCollectionView.collectionViewLayout = flowLayout
        
        let view = UIView()
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: K.BrandColors.purple)
        
        let viewConstraints = [
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            view.topAnchor.constraint(equalTo: self.contactTextField.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(viewConstraints)
        

    }
    
    @IBAction func ContactFieldEditingBegan(_ sender: Any) {
        self.contactTextField.text = ""
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if let indexPath = self.searchNamesTableView.indexPathForSelectedRow {
         let cell  = self.searchNamesTableView.cellForRow(at: indexPath) as? ContactCell
         
         self.otherUserFullName = cell!.nameLabel.text!
         self.otherUserEmail = cell!.email
         
         let userRef = self.db.collection("users").document(self.user!.email!)
         
         userRef.getDocument { (document, error) in
         if let document = document, document.exists {
         let firstName: String = document.data()!["firstName"] as! String
         let lastName: String = document.data()!["lastName"] as! String
         self.userFullName = "\(firstName) \(lastName)"
         } else {
         print("Document does not exist")
         }
         }
         } else {
         print("Cell does not exist")
         }*/
        
        if segue.destination is ChatViewController {
            let vc = segue.destination as! ChatViewController
            vc.otherUserFullName = self.otherUserFullName
            vc.otherUserEmail = self.otherUserEmail
            vc.userFullName = self.userFullName
        }
    }
    
    
    
    //everytime a letter is entered into the search bar it reloads the search names
    @IBAction func ContactTextFieldEditingChanged(_ sender: UITextField) {
        loadSearchNames()
    }
    
    func loadSearchNames() {
        let searchName = contactTextField.text
        
        //goes through whole list of users on app
        userRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.searchNames = []
            for value in postDict.values {
                //creates contact icon for all the users
                let userFirstName = value.object(forKey: "firstName")! as! String
                let userLastName = value.object(forKey: "lastName")! as! String
                let userFullName = "\(userFirstName) \(userLastName)"
                let userEmail = value.object(forKey: "email") as! String
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
        }
    }*/





extension NewConversationViewController: UICollectionViewDataSource{
    //number of icons in collection view based on length of search names
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchNames.count
    }
    
    //sets cells nameLabel to name of person (Contact.fullName) and document ID to person's email (Contact.email)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = searchNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! TestCollectionViewCell
        
        //cell.layer.backgroundColor = UIColor(named: K.BrandColors.backgroundBlack)?.cgColor
        
        cell.isSearchName = true
        cell.contactName.text = searchNames[indexPath.row].fullName
        cell.documentID = searchNames[indexPath.row].email
        cell.profileImageUrl = searchNames[indexPath.row].profileImageUrl

        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, numbelet cell = searchNamesCollectionView.cellForItem(at: indexPath) as! ContactCollectionViewCellrOfRowsInSection section: Int) -> Int {
     return searchNames.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = searchNamesTableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath) as! ContactCell
     
     cell.layer.backgroundColor = UIColor(named: K.BrandColors.backgroundBlack)?.cgColor
     
     cell.nameLabel.text = searchNames[indexPath.row].fullName
     cell.email = searchNames[indexPath.row].email
     
     return cell
     }*/
}

extension NewConversationViewController: UICollectionViewDelegate {
    //if selected, sets proper variables and performs segue
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = searchNamesCollectionView.cellForItem(at: indexPath) as? TestCollectionViewCell {
            
            self.otherUserFullName = cell.contactName.text!
            self.otherUserEmail = cell.documentID
            self.profileImageUrl = cell.profileImageUrl
        }
        
        /*if(user.email! < otherUserEmail ) {
            self.documentName = "\(self.user!.email!) + \(otherUserEmail)"
        } else {
            self.documentName = "\(otherUserEmail) + \(self.user!.email!)"
        }
        
        let commaDocumentName = self.documentName.replacingOccurrences(of: ".", with: ",")
        
        let commaOtherUserEmail = self.otherUserEmail.replacingOccurrences(of: ".", with: ",")
        
        self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/readNotification").setValue(true)*/
        
        performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
    }
    
}

//
//  NewConversationViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/22/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins

class NewConversationViewController: UIViewController {
    
    @IBOutlet weak var searchNamesCollectionView: UICollectionView!
    @IBOutlet weak var contactBarView: UIView!
    @IBOutlet weak var contactTextField: UITextField!
    
    //--//
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    //--//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchNamesCollectionView.register(TestTwoCollectionViewCell.self, forCellWithReuseIdentifier: "contactCollectionViewCell")
        
        navigationController?.navigationBar.barTintColor = .black//UIColor(named: K.BrandColors.backgroundBlack)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationItem.backBarButtonItem?.tintColor = UIColor(named: K.BrandColors.purple)
        self.navigationController!.navigationBar.tintColor = UIColor(named: K.BrandColors.purple);
        
        //setup delegates
        searchNamesCollectionView.dataSource = self
        searchNamesCollectionView.delegate = self
        
        
        //set up collection view for contact cells
        let cellWidth = UIScreen.main.bounds.width/3 - 10
        let cellHeight = cellWidth/0.7
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //pushMessageButton.isEnabled = true
        //pushMessageButton.tintColor = UIColor(named: K.BrandColors.red)
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue.height
        
        self.bottomConstraint.constant = keyboardFrame
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {return}
        
        self.bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
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
            vc.documentID = self.documentName
            vc.isNewChat = true
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
        
        let cell = searchNamesCollectionView.dequeueReusableCell(withReuseIdentifier: "contactCollectionViewCell", for: indexPath) as! TestTwoCollectionViewCell
        
        //cell.layer.backgroundColor = UIColor(named: K.BrandColors.backgroundBlack)?.cgColor
        
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
        
        //cell.profileImageUrl = profileImageUrl
        cell.contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
        
        if profileImageUrl == "default" {
            return cell
        }  else if let cachedImage = self.imageCache.object(forKey: profileImageUrl as NSString) {
            cell.contactImageView.image = cachedImage as? UIImage
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

extension NewConversationViewController: UICollectionViewDelegate {
    //if selected, sets proper variables and performs segue
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = searchNamesCollectionView.cellForItem(at: indexPath) as? TestTwoCollectionViewCell {
            
            let otherUserFirstName = cell.contactFirstName.text ?? "error"
            let otherUserLastName = cell.contactLastName.text ?? ""
            
            let otherUserFullName = "\(otherUserFirstName) \(otherUserLastName)"
            
            self.otherUserFullName = otherUserFullName
            self.otherUserEmail = cell.documentID
            //self.profileImageUrl = cell.profileImageUrl
            
            if(user.email! < otherUserEmail ) {
                var documentName = "\(self.user!.email!) + \(otherUserEmail)"
                self.documentName = documentName.replacingOccurrences(of: ".", with: ",")
            } else {
                var documentName = "\(otherUserEmail) + \(self.user!.email!)"
                self.documentName = documentName.replacingOccurrences(of: ".", with: ",")
            }
            
            /*let commaDocumentName = self.documentName.replacingOccurrences(of: ".", with: ",")
             
             let commaOtherUserEmail = self.otherUserEmail.replacingOccurrences(of: ".", with: ",")
             
             self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/readNotification").setValue(true)*/
            
            performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
        }
        
        
        
        
    }
    
}

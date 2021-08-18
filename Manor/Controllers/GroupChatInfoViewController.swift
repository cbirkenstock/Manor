//
//  GroupChatInfoViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/4/21.
//

import UIKit
import Firebase

class GroupChatInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var addMemberButton: UIButton!
    @IBOutlet weak var pushMessagesTableView: UITableView!
    @IBOutlet weak var groupChatImageButton: UIButton!
    @IBOutlet weak var groupChatTitleTextField: UITextField!
    
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatByUsersRef = Database.database().reference().child("GroupChatsByUser")
    let usersRef = Database.database().reference().child("users")
    var documentID: String?
    var pushMessages: [Message] = []
    var groupMembers: [[String]] = []
    var groupContacts: [Contact] = []
    var tableViewContents: [[Any]] = []
    var sectionHeaderTitles: [String] = ["Buttons", "Members", "Push Messages", "Settings"]
    var groupChatTitle: String = ""
    var pushMessageUID: String = ""
    var userFullName: String = ""
    var groupChatImageUrl: String = ""
    var otherUserFullName: String = ""
    var otherUserEmail: String = ""
    var notificationsOn: Bool?
    var userEmail: String = ""
    var userNickName: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableSwipe"), object: nil)
        
        let buttonsArray = ["Add Members", "Notifications:"]
        
        self.tableViewContents.append(buttonsArray)
        
        groupChatImageButton.layer.cornerRadius = groupChatImageButton.frame.height/2
        groupChatImageButton.clipsToBounds = true
        
        groupChatTitleTextField.isUserInteractionEnabled = false
        
        self.downloadImage { image in
            self.groupChatImageButton.setBackgroundImage(image, for: .normal)
            self.groupChatTitleTextField.text = self.groupChatTitle
        }
        
        self.view.backgroundColor = .black
        
        self.groupChatTitleTextField.text = self.groupChatTitle
        
        setUpAddMemberButton()
        
        pushMessagesTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: "MemberCell")
        
        pushMessagesTableView.separatorStyle = .none
        
        
        /*for email in groupMembers {
            let currentUserEmail = email
            var currentUserFullName = ""
            let commaEmail = email.replacingOccurrences(of: ".", with: ",")
            usersRef.child(commaEmail).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                let postDict = snapshot.value as? [String: AnyObject]
                for key in postDict!.keys {
                    if key == "firstName" {
                        currentUserFullName = (self.value(forKey: "firstName") as? String) ?? ""
                    }
                    
                    if key == "lastName" {
                        currentUserFullName = "\(currentUserFullName) \(self.value(forKey: "lastName") as? String ?? "")"
                        
                        let user = Contact(email: currentUserEmail, fullName: currentUserFullName)
                        
                        self.groupContacts.append(user)
                    }
                }
            }
        }*/
        
        for member in groupMembers {
            if member[0] == self.userFullName {
                self.userEmail = member[1]
            }
        }
        
        tableViewContents.append(groupMembers)
        
        
        pushMessagesTableView.dataSource = self
        pushMessagesTableView.delegate = self
        
        let pushMessagesRef = groupChatMessagesRef.child(documentID!).child("pushMessages")
        
        pushMessagesRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.pushMessages = []
            for (key, value) in postDict {
                if let messageSender = value.object(forKey: "messageSender")! as? String, let messageBody = value.object(forKey: "messageBody") as? String, let commaTimeStamp = value.object(forKey: "timeStamp") as? String {
                    let timeStamp = Double(commaTimeStamp.replacingOccurrences(of: ",", with: "."))!
                    let message = Message(messageSender: messageSender, messageBody: messageBody, timeStamp: timeStamp, pushMessageUID: key)
                    self.pushMessages.append(message)
                    DispatchQueue.main.async {
                        self.pushMessagesTableView.reloadData()
                        /*let indexPath = IndexPath(row: self.pushMessages.count - 1, section: 0)
                         self.pushMessagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)*/
                    }
                    
                }
            }
            
            let sortedPushMessages = self.pushMessages.sorted(by: { $0.timeStamp < $1.timeStamp })
            
            self.tableViewContents.append(sortedPushMessages)
            
            let settingsArray = ["Nickname:", "Leave Chat"]
            
            self.tableViewContents.append(settingsArray)
            
            DispatchQueue.main.async {
                self.pushMessagesTableView.reloadData()
                /*let indexPath = IndexPath(row: self.pushMessages.count - 1, section: 0)
                 self.pushMessagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)*/
            }
        })
        

        
        /*self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID!).child("notificationsEnabled").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
            if let notificationsEnabled = DataSnapshot.value as? Bool {
                if notificationsEnabled {
                    self.notificationsOn = true
                } else {
                    self.notificationsOn = false
                }
            } else {
                self.notificationsOn = true
            }
            self.pushMessagesTableView.reloadData()
        }*/
    }
    
    func setUpAddMemberButton() {
        //self.addMemberButton.layer.cornerRadius = 10
        //self.addMemberButton.backgroundColor = UIColor(named: K.BrandColors.purple)//UIColor(named: K.BrandColors.navigationBarGray)
    }
    
    @IBAction func ProfilePicturePressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true)
    }
    
    func downloadImage(completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async { [weak self] in
            if var groupChatImageUrl = self?.groupChatImageUrl {
                if groupChatImageUrl == "" {
                    groupChatImageUrl = "default"
                }
                let URL = URL(string: groupChatImageUrl)
                if let data = try? Data(contentsOf: URL!) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            let imageName = NSUUID().uuidString
            let storage = Storage.storage()
            let ref = storage.reference().child("Contact_images").child(imageName)
            
            if let uploadData = selectedImage.jpegData(compressionQuality: 0.2) {
                ref.putData(uploadData, metadata: nil) { metaData, err in
                    
                    if err != nil {
                        print("failed to upload image:", err!)
                        return
                    }
                    
                    ref.downloadURL { url, err in
                        if err != nil {
                            print("failed to download URL", err!)
                        } else if let imageURL = url?.absoluteString {
                            self.groupChatMessagesRef.child("\(self.documentID!)/profileImageUrl").setValue(imageURL)
                            self.groupChatImageUrl = imageURL
                            self.downloadImage { image in
                                self.groupChatImageButton.setBackgroundImage(image, for: .normal)
                                self.groupChatTitleTextField.text = self.groupChatTitle
                            }
                            
                            for member in self.groupMembers {
                                let commaEmail = member[1].replacingOccurrences(of: ".", with: ",")
                                
                                self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/profileImageUrl").setValue(imageURL)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddMembersViewController {
            let vc = segue.destination as! AddMembersViewController
            vc.documentID = self.documentID!
            vc.groupMembers = self.groupMembers
            vc.groupChatTitle = self.groupChatTitle
        }
        
        if segue.destination is UnreachedMembersViewController {
            let vc = segue.destination as! UnreachedMembersViewController
            vc.pushMessageUID = self.pushMessageUID
            vc.groupMembers = self.groupMembers
            vc.documentID = self.documentID!
            vc.userFullName = self.userFullName
        }
        
        if segue.destination is ChatViewController {
            let vc = segue.destination as! ChatViewController
            vc.otherUserFullName = self.otherUserFullName
            vc.otherUserEmail = self.otherUserEmail
            vc.userFullName = self.userFullName
        }
    }
    
    
    func addMembersButtonPressed() {
        performSegue(withIdentifier: "toAddMembers", sender: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableSwipe"), object: nil)
    }
}


extension GroupChatInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewContents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewContents[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pushMessagesTableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.isContact = false
            let name = tableViewContents[indexPath.section][indexPath.row] as? String
            cell.contactName.text = name
            if name == "Add Members" {
                cell.background.backgroundColor = UIColor(named: K.BrandColors.purple)
            } else {
                cell.isSettingsButton = true
                
                let commaEmail = self.userEmail.replacingOccurrences(of: ".", with: ",")
                
                
                self.groupChatByUsersRef.child(commaEmail).child("Chats").child(self.documentID!).child("notificationsEnabled").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                    if let notificationsEnabled = DataSnapshot.value as? Bool {
                        if notificationsEnabled {
                            cell.specificTextFieldText = "Enabled"
                            cell.background.backgroundColor = .systemGreen
                        } else {
                            cell.specificTextFieldText = "Disabled"
                            cell.background.backgroundColor = .systemRed
                        }
                    }
                }
            }
        case 1:
            let email = groupMembers[indexPath.row][1]
            cell.contactEmail = email
            
            
            cell.isContact = true
            
            let name = groupMembers[indexPath.row][0]
            cell.contactName.text = name
            
        case 2:
            cell.isContact = false
            let message = tableViewContents[indexPath.section][indexPath.row] as? Message
            cell.contactName.text = message?.messageBody
            cell.pushMessageUID = message?.pushMessageUID ?? ""
        case 3:
            cell.isContact = false
            if indexPath.row == 0 {
                cell.specificTextFieldText = self.userNickName
                let email = tableViewContents[indexPath.section][indexPath.row] as? String
                cell.contactName.text = email
                cell.isSettingsButton = true
            } else {
                let title = tableViewContents[indexPath.section][indexPath.row] as? String
                cell.contactName.text = title
                cell.contactName.textColor = .systemRed
                cell.contactName.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            }
        default:
            cell.isContact = false
            let email = tableViewContents[indexPath.section][indexPath.row] as? String
            cell.contactName.text = email
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerHeight: CGFloat
        
        switch section {
        case 0:
            // hide the header
            headerHeight = CGFloat.leastNonzeroMagnitude
        case 2:
            if tableViewContents[section].count == 0 {
                headerHeight = CGFloat.leastNonzeroMagnitude
            } else {
                headerHeight = 20
            }
        default:
            headerHeight = 20
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            return nil
        case 2:
            if tableViewContents[section].count == 0 {
                return nil
            } else {
                let headerLabel = UILabel()
                headerLabel.backgroundColor = .clear
                headerLabel.text = self.sectionHeaderTitles[section]
                headerLabel.textColor = .white
                headerLabel.textAlignment = .center
                headerLabel.translatesAutoresizingMaskIntoConstraints = false
                headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
                
                let containerView = UIView()
                containerView.addSubview(headerLabel)
                containerView.backgroundColor = .black
                
                let headerViewConstraints = [
                    //headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                    //headerLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor),
                    headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    headerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
                ]
                
                NSLayoutConstraint.activate(headerViewConstraints)
                
                return containerView
            }
        default:
            let headerLabel = UILabel()
            headerLabel.backgroundColor = .clear
            headerLabel.text = self.sectionHeaderTitles[section]
            headerLabel.textColor = .white
            headerLabel.textAlignment = .center
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
            let containerView = UIView()
            containerView.addSubview(headerLabel)
            containerView.backgroundColor = .black//UIColor.init(named: K.BrandColors.backgroundBlack)
            
            let headerViewConstraints = [
                //headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                //headerLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor),
                headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                headerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ]
            
            NSLayoutConstraint.activate(headerViewConstraints)
            
            return containerView
        }
        /*let containerViewConstraints = [
         containerView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: -10)
         ]*/
        //containerView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = pushMessagesTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! RegularMessageBody
        
        let cell = pushMessagesTableView.cellForRow(at: indexPath) as! MemberTableViewCell
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                addMembersButtonPressed()
            }
            if indexPath.row == 1 {
                let commaEmail = self.userEmail.replacingOccurrences(of: ".", with: ",")
                if self.notificationsOn ?? true {
                    cell.background.backgroundColor = .systemRed
                    cell.specificTextField.text = "Disabled"
                    self.notificationsOn = false
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/notificationsEnabled").setValue(false)
                } else {
                    cell.background.backgroundColor = .systemGreen
                    cell.specificTextField.text = "Enabled"
                    self.notificationsOn = true
                    self.groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/notificationsEnabled").setValue(true)
                }
            }
        case 1:
            self.otherUserFullName = cell.contactName.text!
            self.otherUserEmail = groupMembers[indexPath.row][1]
            performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
        case 2:
            cell.selectionStyle = .none
            self.pushMessageUID = cell.pushMessageUID
            performSegue(withIdentifier: "toUnreachedMembers", sender: self)
        case 3:
            cell.selectionStyle = .none
            cell.specificTextField.isUserInteractionEnabled = true
            cell.specificTextField.delegate = self
            cell.specificTextField.text = ""
            cell.specificTextField.textAlignment = .center
            cell.specificTextField.becomeFirstResponder()
            
        default:
            cell.selectionStyle = .none
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.textAlignment = .right
        textField.resignFirstResponder()
        
        let commaEmail = self.userEmail.replacingOccurrences(of: ".", with: ",")
        
        if textField.text != "" {
        groupChatByUsersRef.child("\(commaEmail)/Chats/\(self.documentID!)/nickName").setValue(textField.text)
        } else {
            textField.text = self.userFullName
        }
        
        return true
    }
    
}


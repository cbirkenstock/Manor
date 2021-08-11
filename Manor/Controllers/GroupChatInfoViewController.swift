//
//  GroupChatInfoViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/4/21.
//

import UIKit
import Firebase

class GroupChatInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var addMemberButton: UIButton!
    @IBOutlet weak var pushMessagesTableView: UITableView!
    @IBOutlet weak var groupChatImageButton: UIButton!
    @IBOutlet weak var groupChatTitleTextField: UITextField!
    
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatByUsersRef = Database.database().reference().child("GroupChatsByUser")
    let usersRef = Database.database().reference().child("users")
    var documentID: String?
    var pushMessages: [Message] = []
    var groupMembers: [String] = []
    var groupContacts: [Contact] = []
    var tableViewContents: [[Any]] = []
    var sectionHeaderTitles: [String] = ["Members", "Push Messages", "Settings"]
    var groupChatTitle: String = ""
    var pushMessageUID: String = ""
    var userFullName: String = ""
    var groupChatImageUrl: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupChatImageButton.layer.cornerRadius = groupChatImageButton.frame.height/2
        
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
            
            DispatchQueue.main.async {
                self.pushMessagesTableView.reloadData()
                /*let indexPath = IndexPath(row: self.pushMessages.count - 1, section: 0)
                 self.pushMessagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)*/
            }
        })
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func setUpAddMemberButton() {
        self.addMemberButton.layer.cornerRadius = 10
        self.addMemberButton.backgroundColor = UIColor(named: K.BrandColors.purple)//UIColor(named: K.BrandColors.navigationBarGray)
    }
    
    @IBAction func ProfilePicturePressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true)
    }
    
    func downloadImage(completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async { [weak self] in
            let URL = URL(string: self?.groupChatImageUrl ?? "default")
            if let data = try? Data(contentsOf: URL!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
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
                            
                            for email in self.groupMembers {
                                let commaEmail = email.replacingOccurrences(of: ".", with: ",")
                                
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
    }
    
    
    @IBAction func addMembersButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddMembers", sender: self)
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
        
        if indexPath.section == 0 {
            let email = tableViewContents[indexPath.section][indexPath.row] as! String
            cell.contactName.text = email
        }
        
        if indexPath.section == 1 {
            let message = tableViewContents[indexPath.section][indexPath.row] as! Message
            cell.contactName.text = message.messageBody
            cell.pushMessageUID = message.pushMessageUID ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = UILabel()
        headerLabel.backgroundColor = .clear
        headerLabel.text = self.sectionHeaderTitles[section]
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
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
        
        /*let containerViewConstraints = [
         containerView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: -10)
         ]*/
        //containerView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return containerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = pushMessagesTableView.dequeueReusableCell(withIdentifier: "regularMessageCell", for: indexPath) as! RegularMessageBody
        
        let cell = pushMessagesTableView.cellForRow(at: indexPath) as! MemberTableViewCell
        
        self.pushMessageUID = cell.pushMessageUID
        
        performSegue(withIdentifier: "toUnreachedMembers", sender: self)
    }
}


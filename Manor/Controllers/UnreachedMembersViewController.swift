//
//  UnreachedMembersViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/20/21.
//

import UIKit
import Firebase
import WebKit
//import ShowTime

class UnreachedMembersViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var unreachedMembersTableView: UITableView!
    var unreachedMembers: [[String]] = []
    var pushMessageUID: String = ""
    var groupMembers: [[String]] = []
    var documentID: String = ""
    let groupChatsByUserRef = Database.database().reference().child("GroupChatsByUser")
    var webView: WKWebView!
    var user: User! = Firebase.Auth.auth().currentUser
    var documentName: String = ""
    var userFullName: String = ""
    let chatMessagesRef = Database.database().reference().child("ChatMessages")
    let chatsByUserRef = Database.database().reference().child("ChatsByUser")
    var otherUserFullName: String = ""
    var otherUserEmail: String = ""
    
    @IBOutlet weak var unreachedMembersBottomConstraint: NSLayoutConstraint!
    /*override func loadView() {
     webView = WKWebView()
     webView.navigationDelegate = self
     view = webView
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ShowTime.enabled = .never
        
        
        loadUnreachedMembers()
        
        //webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        
        /*let url = URL(string: "https://account.venmo.com/pay?recipients=George-Lawrence-13&amount=0.01")!
         webView.load(URLRequest(url: url))
         webView.allowsBackForwardNavigationGestures = true*/
        /*print(pushMessageUID)
         print(groupMembers.count)
         print(documentID)*/
        
        unreachedMembersTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: "MemberCell")
        unreachedMembersTableView.dataSource = self
        unreachedMembersTableView.delegate = self
    }
    
    /*override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
     if keyPath == "title" {
     if let title = webView.title {
     let url = URL(string: "https://account.venmo.com/pay?recipients=George-Lawrence-13&amount=0.01")!
     webView.load(URLRequest(url: url))
     webView.allowsBackForwardNavigationGestures = true
     }
     }
     }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChatViewController {
            let vc = segue.destination as! ChatViewController
            vc.otherUserFullName = self.otherUserFullName
            vc.otherUserEmail = self.otherUserEmail
            vc.userFullName = self.userFullName
            
            if(self.user.email! < otherUserEmail ) {
                let chatTitle = "\(self.user!.email!) + \(otherUserEmail)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            } else {
                let chatTitle = "\(otherUserEmail) + \(self.user!.email!)"
                vc.documentID = chatTitle.replacingOccurrences(of: ".", with: ",")
            }
        }
    }
    
    @IBAction func messageAllButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Send Message", message: "Your message will be sent to everyone once you hit send", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { UIAlertAction in
            print(UIAlertAction)
            let answer = alert.textFields![0].text
            for member in self.groupMembers {
                if answer != "" {
                    
                    let commaOtherUserEmail = member[1].replacingOccurrences(of: ".", with: ",")
                    let commaUserEmail = self.user.email!.replacingOccurrences(of: ".", with: ",")
                    
                    let messageBody = answer
                    
                    let timeStamp = Date().timeIntervalSince1970
                    let timeStampString = ("\(timeStamp)")
                    let commaTimeStamp =  timeStampString.replacingOccurrences(of: ".", with: ",")
                    
                    let email = member[1]
                    
                    if(self.user.email! < email ) {
                        self.documentName = "\(self.user!.email!) + \(email)"
                    } else {
                        self.documentName = "\(email) + \(self.user!.email!)"
                    }
                    
                    let commaDocumentName = self.documentName.replacingOccurrences(of: ".", with: ",")
                    
                    
                    self.chatMessagesRef.child(commaDocumentName).child("Messages").child(commaTimeStamp).setValue([
                        "messageSender": self.userFullName,
                        "messageBody": messageBody!,
                        "timeStamp": timeStamp
                    ])
                    
                    self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/senderEmail").setValue(commaUserEmail)
                    
                    self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/lastMessage").setValue(messageBody)
                    
                    self.chatsByUserRef.child("\(commaUserEmail)/Chats/\(commaDocumentName)/timeStamp").setValue(timeStamp)
                    
                    self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/senderEmail").setValue(commaUserEmail)
                    
                    self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/lastMessage").setValue(messageBody)
                    
                    self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/timeStamp").setValue(timeStamp)

                    self.chatsByUserRef.child("\(commaOtherUserEmail)/Chats/\(commaDocumentName)/readNotification").setValue(false)
                    
                }
            }
            
        }))
        
        self.present(alert, animated: true)
        
    }
    
    func loadUnreachedMembers() {
        for member in groupMembers {
            let email = member[1]
            let commaEmail = email.replacingOccurrences(of: ".", with: ",")
            let name = member[0]
            
            groupChatsByUserRef.child(commaEmail).child("Chats").child(documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                let postArray = DataSnapshot.value as? [String] ?? []
                print("postarray")
                print(postArray)
                if postArray.contains(self.pushMessageUID) {
                    self.unreachedMembers.append([name, email])
                    DispatchQueue.main.async {
                        self.unreachedMembersTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension UnreachedMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unreachedMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = unreachedMembersTableView.dequeueReusableCell(withIdentifier: "MemberCell") as! MemberTableViewCell
        
        let email = unreachedMembers[indexPath.row][1]
        cell.contactEmail = email
        cell.background.backgroundColor = UIColor(named: K.BrandColors.navigationBarGray)
        cell.contactName.textColor = .white
        cell.contactName.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        
        cell.isContact = true
        cell.isSettingsButton = false
        
        let name = unreachedMembers[indexPath.row][0]
        cell.contactName.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = unreachedMembersTableView.cellForRow(at: indexPath) as! MemberTableViewCell
        cell.selectionStyle = .none
        
        if let otherUserFullName = cell.contactName.text, unreachedMembers.count - 1 >= indexPath.row, unreachedMembers[indexPath.row].count == 2 {
            let otherUserEmail = unreachedMembers[indexPath.row][1]
            if otherUserFullName != "", otherUserEmail != "" {
                self.otherUserFullName = otherUserFullName
                self.otherUserEmail = otherUserEmail
                performSegue(withIdentifier: K.Segues.DirectMessageChatSegue, sender: self)
            }
        } else {
            print(cell.contactName)
            print(unreachedMembers.count - 1 >= indexPath.row)
            print(unreachedMembers[indexPath.row].count == 2)
        }
    }
}

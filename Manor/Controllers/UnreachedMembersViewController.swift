//
//  UnreachedMembersViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/20/21.
//

import UIKit
import Firebase
import WebKit

class UnreachedMembersViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var unreachedMembersTableView: UITableView!
    var unreachedMembers: [String] = []
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
    
    @IBOutlet weak var unreachedMembersBottomConstraint: NSLayoutConstraint!
    /*override func loadView() {
     webView = WKWebView()
     webView.navigationDelegate = self
     view = webView
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func messageAllButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Send Message", message: "Your message will be sent to everyone once you hit send", preferredStyle: .alert)
        alert.addTextField()
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
            
            groupChatsByUserRef.child(commaEmail).child("Chats").child(documentID).child("unreadPushMessages").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                let postArray = DataSnapshot.value as? [String] ?? []
                print(postArray)
                if postArray.contains(self.pushMessageUID) {
                    self.unreachedMembers.append(email)
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
        
        cell.isContact = false
        cell.contactName.text = unreachedMembers[indexPath.row]
        
        return cell
    }
}

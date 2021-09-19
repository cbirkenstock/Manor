//
//  EventTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/30/21.
//

import UIKit
import Firebase

class EventTableViewCell: UITableViewCell {
    
    let db = Firestore.firestore()
    var user: User! = Firebase.Auth.auth().currentUser
    let eventChatsByUserRef =
        Database.database().reference().child("EventChatsByUser")
    let eventChatMessagesRef = Database.database().reference().child("EventChatMessages")
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")
    let groupChatByUsersRef = Database.database().reference().child("GroupChatsByUser")
    var messageSender: String?
    var userFullName: String?
    var documentID: String?
    var groupMembers: [[String]]?
    var messageTimeStamp: Double?
    var GroupChatVCInstace: UIViewController?
    var groupChatDocumentID: String! {
        didSet {
            let commaMessageTimeStamp = self.messageTimeStamp?.description.replacingOccurrences(of: ".", with: ",")
            
            self.groupChatMessagesRef.child(self.groupChatDocumentID!).child("Messages").child("Message,\(commaMessageTimeStamp!)").child("currentNumber").observeSingleEvent(of: DataEventType.value, with: { DataSnapshot in
                if let currentNumber = DataSnapshot.value as? String {
                    self.currentNumber.text = currentNumber
                    self.updateSpace()
                }
            })
        }
    }
    
    let joinEventButton: UIButton = {
        let joinEventButton = UIButton()
        joinEventButton.translatesAutoresizingMaskIntoConstraints = false
        joinEventButton.backgroundColor = .clear
        return joinEventButton
    }()
    
    let eventContainer: UIImageView = {
        let eventContainer = UIImageView()
        eventContainer.translatesAutoresizingMaskIntoConstraints = false
        eventContainer.layer.cornerRadius = 10
        eventContainer.backgroundColor = .systemGreen
        //eventContainer.image = #imageLiteral(resourceName: "AbstractPainting")
        //eventContainer.clipsToBounds = true
        //eventContainer.contentMode = .scaleToFill
        return eventContainer
    }()
    
    let titleContainer: UIView = {
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = UIColor(named: "Gray")
        titleContainer.clipsToBounds = true
        titleContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        titleContainer.layer.cornerRadius = 10
        return titleContainer
    }()
    
    let titleTextField: UILabel = {
        let titleTextField = UILabel()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        titleTextField.textColor = .white
        titleTextField.numberOfLines = 0
        titleTextField.textAlignment = .center
        return titleTextField
    }()
    
    let timeContainer: UIView = {
        let timeContainer = UIView()
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        timeContainer.backgroundColor = .clear
        timeContainer.clipsToBounds = true
        timeContainer.layer.borderWidth = 2
        timeContainer.layer.cornerRadius = 10
        timeContainer.layer.borderColor = UIColor.white.cgColor
        return timeContainer
    }()
    
    let timeTextField: UILabel = {
        let timeTextField = UILabel()
        timeTextField.translatesAutoresizingMaskIntoConstraints = false
        timeTextField.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        timeTextField.textColor = .white
        timeTextField.numberOfLines = 0
        timeTextField.textAlignment = .center
        return timeTextField
    }()
    
    //let timeTextField = "yo"
    
    let bodyContainer: UIView = {
        let bodyContainer = UIView()
        bodyContainer.translatesAutoresizingMaskIntoConstraints = false
        bodyContainer.backgroundColor = .clear
        bodyContainer.layer.cornerRadius = 10
        bodyContainer.clipsToBounds = true
        return bodyContainer
    }()
    
    let bodyTextField: UILabel = {
        let bodyTextField = UILabel()
        bodyTextField.translatesAutoresizingMaskIntoConstraints = false
        bodyTextField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        bodyTextField.textColor = .white
        bodyTextField.numberOfLines = 0
        bodyTextField.textAlignment = .center
        return bodyTextField
    }()
    
    let fractionLine: UIView = {
        let fractionLine = UIView()
        fractionLine.translatesAutoresizingMaskIntoConstraints = false
        fractionLine.backgroundColor = .white
        return fractionLine
    }()
    
    let currentNumber: UILabel = {
        var currentNumber = UILabel()
        currentNumber.text = "5"
        currentNumber.translatesAutoresizingMaskIntoConstraints = false
        currentNumber.font = UIFont.systemFont(ofSize: 30)
        currentNumber.backgroundColor = .systemGreen
        currentNumber.layer.masksToBounds = true
        currentNumber.layer.cornerRadius = 40/2
        currentNumber.textAlignment = .center
        return currentNumber
    }()
    
    let eventCap: UILabel = {
        let eventCap = UILabel()
        eventCap.translatesAutoresizingMaskIntoConstraints = false
        eventCap.text = "15"
        eventCap.font = UIFont.systemFont(ofSize: 30)
        eventCap.backgroundColor = .systemGreen
        eventCap.layer.masksToBounds = true
        eventCap.layer.cornerRadius = 40/2
        eventCap.textAlignment = .center
        return eventCap
    }()
    
    /*var alreadyJoined: Bool! {
     didSet {
     let commaMessageTimeStamp = self.messageTimeStamp?.description.replacingOccurrences(of: ".", with: ",")
     
     if !alreadyJoined {
     //updateNumber(commaMessageTimeStamp: commaMessageTimeStamp!)
     //self.alreadyJoined = false
     }
     }
     }*/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        contentView.addSubview(eventContainer)
        eventContainer.addSubview(titleContainer)
        titleContainer.addSubview(titleTextField)
        eventContainer.addSubview(timeContainer)
        timeContainer.addSubview(timeTextField)
        eventContainer.addSubview(bodyContainer)
        bodyContainer.addSubview(bodyTextField)
        contentView.addSubview(fractionLine)
        contentView.addSubview(currentNumber)
        contentView.addSubview(eventCap)
        contentView.addSubview(joinEventButton)
        joinEventButton.addTarget(self, action: #selector(joinEvent), for: .touchUpInside)
        
        let titleTextFieldConstraints = [
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(titleTextFieldConstraints)
        
        let titleContainerConstraints = [
            titleContainer.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -3),
            titleContainer.bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 3),
            titleContainer.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor, constant: -10),
            titleContainer.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(titleContainerConstraints)
        
        let timeTextFieldConstraints = [
            timeTextField.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 10),
            timeTextField.bottomAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 0),
            timeTextField.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor, constant: 0)
            //timeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            //timeTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(timeTextFieldConstraints)
        
        let timeContainerConstraints = [
            timeContainer.topAnchor.constraint(equalTo: timeTextField.topAnchor, constant: -5),
            timeContainer.bottomAnchor.constraint(equalTo: timeTextField.bottomAnchor, constant: 5),
            timeContainer.leadingAnchor.constraint(equalTo: timeTextField.leadingAnchor, constant: -10),
            timeContainer.trailingAnchor.constraint(equalTo: timeTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(timeContainerConstraints)
        
        let bodyTextFieldConstraints = [
            bodyTextField.topAnchor.constraint(equalTo: timeContainer.bottomAnchor, constant: 10),
            bodyTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            bodyTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bodyTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(bodyTextFieldConstraints)
        
        let bodyContainerConstraints = [
            bodyContainer.topAnchor.constraint(equalTo: bodyTextField.topAnchor, constant: -5),
            bodyContainer.bottomAnchor.constraint(equalTo: bodyTextField.bottomAnchor, constant: 5),
            bodyContainer.leadingAnchor.constraint(equalTo: bodyTextField.leadingAnchor, constant: -10),
            bodyContainer.trailingAnchor.constraint(equalTo: bodyTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(bodyContainerConstraints)
        
        let eventContainerConstraints = [
            eventContainer.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 0),
            eventContainer.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor, constant: 0),
            eventContainer.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 0),
            eventContainer.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(eventContainerConstraints)
        
        let fractionLineConstraints = [
            fractionLine.centerYAnchor.constraint(equalTo: eventContainer.centerYAnchor, constant: 0),
            fractionLine.leadingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: 20),
            fractionLine.heightAnchor.constraint(equalToConstant: 2),
            fractionLine.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(fractionLineConstraints)
        
        let currentNumberConstraints = [
            currentNumber.bottomAnchor.constraint(equalTo: fractionLine.topAnchor, constant: -5),
            currentNumber.heightAnchor.constraint(equalToConstant: 40),
            currentNumber.leadingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: 20),
            currentNumber.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(currentNumberConstraints)
        
        let eventCapConstraints = [
            eventCap.topAnchor.constraint(equalTo: fractionLine.bottomAnchor, constant: 5),
            eventCap.heightAnchor.constraint(equalToConstant: 40),
            eventCap.leadingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: 20),
            eventCap.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(eventCapConstraints)
        
        let joinEventButtonConstraints = [
            joinEventButton.topAnchor.constraint(equalTo: eventContainer.topAnchor, constant: 0),
            joinEventButton.bottomAnchor.constraint(equalTo: eventContainer.bottomAnchor, constant: 0),
            joinEventButton.leadingAnchor.constraint(equalTo: eventContainer.leadingAnchor, constant: 0),
            joinEventButton.trailingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(joinEventButtonConstraints)
        
        
        
        //eventContainer.image = #imageLiteral(resourceName: "AbstractPainting")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSpace() {
        if self.eventCap.text == "No Limit" {
            self.eventContainer.backgroundColor = .systemGreen
            self.currentNumber.backgroundColor = .clear
            self.eventCap.backgroundColor = .clear
        } else if let currentNumberInt = Int(self.currentNumber.text ?? "5"), let eventCapInt = Int(self.eventCap.text ?? "15") {
            if currentNumberInt < eventCapInt {
                self.eventContainer.backgroundColor = .systemGreen
                self.currentNumber.backgroundColor = .systemGreen
                self.eventCap.backgroundColor = .systemGreen
            } else {
                self.eventContainer.backgroundColor = .systemRed
                self.currentNumber.backgroundColor = .systemRed
                self.eventCap.backgroundColor = .systemRed
            }
        }
    }
    
    func updateNumber(commaMessageTimeStamp: String) {
        self.groupChatMessagesRef.child(self.groupChatDocumentID!).child("Messages").child("Message,\(commaMessageTimeStamp)").child("currentNumber").observeSingleEvent(of: DataEventType.value, with: { DataSnapshot in
            if let currentnumber = DataSnapshot.value as? String {
                let newCurrentNumber = String(Int(currentnumber)! + 1)
                self.currentNumber.text = newCurrentNumber
                self.updateSpace()
                self.currentNumber.text = newCurrentNumber
                self.groupChatMessagesRef.child("\(self.groupChatDocumentID!)/Messages/Message,\(commaMessageTimeStamp)/currentNumber").setValue(newCurrentNumber)
            }
        })
    }
    
    @objc func joinEvent() {
        if self.messageSender == self.userFullName {
            return
        } else {
            let alreadyJoinedAlert = UIAlertController(title: "Already Joined!", message: "You've already joined this event! Check your homescreen", preferredStyle: .alert)
            alreadyJoinedAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            let isFullAlert = UIAlertController(title: "Event Full", message: "Sorry, this event is Full", preferredStyle: .alert)
            isFullAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            let alert = UIAlertController(title: "Join \(self.titleTextField.text ?? "")?", message: "The event will be added to your events row on the homescreen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { UIAlertAction in
                let timeStamp = Date().timeIntervalSince1970
                let stringTimestamp = "\(timeStamp)"
                let commaTimestamp = stringTimestamp.replacingOccurrences(of: ".", with: ",")
                
                let commaEmail = self.user.email?.replacingOccurrences(of: ".", with: ",")
                
                let commaMessageTimeStamp = self.messageTimeStamp?.description.replacingOccurrences(of: ".", with: ",")
                
                self.eventChatMessagesRef.child(self.documentID!).child("Members").observeSingleEvent(of: DataEventType.value, with: { DataSnapshot in
                    if let postString = DataSnapshot.value as? [[String]], let eventDocumentID = self.documentID {
                        self.groupMembers = postString
                        let userInfo = [self.userFullName!, self.user!.email!]
                        let alreadyJoined = self.groupMembers?.contains(userInfo)
                        var isFull: Bool?
                        
                        print(self.eventCap.text)
                        print(self.currentNumber.text)
                        
                        if self.eventCap.text == "No Limit" {
                            isFull = false
                        } else if let eventCapInt = Int(self.eventCap.text ?? "0"), let currentNumberInt = Int(self.currentNumber.text ?? "0") {
                            if eventCapInt <= currentNumberInt {
                                isFull = true
                            } else {
                                isFull = false
                            }
                        } else {
                            isFull = false
                        }
                        
                        if (alreadyJoined ?? true) || (isFull ?? true) {
                            if (alreadyJoined ?? true) {
                                self.GroupChatVCInstace?.present(alreadyJoinedAlert, animated: true)
                                return
                            }
                            
                            if (isFull ?? true) {
                                self.GroupChatVCInstace?.present(isFullAlert, animated: true, completion: nil)
                                return
                            }
                        }
                        
                        self.updateNumber(commaMessageTimeStamp: commaMessageTimeStamp!)
                        
                        self.groupMembers?.append(userInfo)
                        self.eventChatMessagesRef.child("\(self.documentID!)/Members").setValue(self.groupMembers)
                        
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/title").setValue(self.titleTextField.text)
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/documentID").setValue(eventDocumentID)
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/lastMessage").setValue("")
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/profileImageUrl").setValue("default")
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/notificationsEnabled").setValue(true)
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/timeStamp").setValue(commaTimestamp)
                        self.eventChatsByUserRef.child("\(commaEmail!)/Chats/\(eventDocumentID)/readNotification").setValue(false)
                    }
                })
            }))
            self.GroupChatVCInstace!.present(alert, animated: true)
        }
    }
}

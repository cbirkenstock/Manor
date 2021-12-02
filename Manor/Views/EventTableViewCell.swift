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
        eventContainer.backgroundColor = .clear
        eventContainer.image = #imageLiteral(resourceName: "Beach")
        eventContainer.clipsToBounds = true
        eventContainer.contentMode = .scaleAspectFill
        return eventContainer
    }()
    
    let titleContainer: UIView = {
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        //titleContainer.backgroundColor = .black.withAlphaComponent(0.25)
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
        //timeContainer.layer.borderWidth = 2
        //timeContainer.layer.cornerRadius = 10
        //timeContainer.layer.borderColor = UIColor.white.cgColor
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
        //bodyContainer.layer.cornerRadius = 10
        bodyContainer.clipsToBounds = true
        return bodyContainer
    }()
    
    let bodyTextField: UILabel = {
        let bodyTextField = UILabel()
        bodyTextField.translatesAutoresizingMaskIntoConstraints = false
        bodyTextField.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        bodyTextField.textColor = .white
        bodyTextField.numberOfLines = 0
        bodyTextField.textAlignment = .center
        return bodyTextField
    }()
    
    let fractionLine: UIView = {
        let fractionLine = UIView()
        fractionLine.translatesAutoresizingMaskIntoConstraints = false
        fractionLine.backgroundColor = .clear
        return fractionLine
    }()
    
    let currentNumber: UILabel = {
        var currentNumber = UILabel()
        currentNumber.text = "5"
        currentNumber.translatesAutoresizingMaskIntoConstraints = false
        currentNumber.font = UIFont.systemFont(ofSize: 30)
        currentNumber.backgroundColor = .clear
        currentNumber.layer.borderColor = UIColor.clear.cgColor
        currentNumber.layer.borderWidth = 2
        currentNumber.layer.masksToBounds = true
        currentNumber.layer.cornerRadius = 40/2
        currentNumber.textAlignment = .center
        currentNumber.textColor = .clear
        return currentNumber
    }()
    
    let eventCap: UILabel = {
        let eventCap = UILabel()
        eventCap.translatesAutoresizingMaskIntoConstraints = false
        eventCap.text = "15"
        eventCap.font = UIFont.systemFont(ofSize: 30)
        eventCap.backgroundColor = .clear
        eventCap.layer.borderColor = UIColor.clear.cgColor
        eventCap.layer.borderWidth = 2
        eventCap.layer.masksToBounds = true
        eventCap.layer.cornerRadius = 40/2
        eventCap.textAlignment = .center
        eventCap.textColor = .clear
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
        
        let eventWidth = UIScreen.main.bounds.width - 115
        
        let eventContainerConstraints = [
            eventContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            eventContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            eventContainer.widthAnchor.constraint(equalToConstant: eventWidth),
            eventContainer.heightAnchor.constraint(equalToConstant: eventWidth + 87.5)
        ]
        
        NSLayoutConstraint.activate(eventContainerConstraints)
        
        let titleTextFieldConstraints = [
            titleTextField.topAnchor.constraint(equalTo: eventContainer.topAnchor, constant: 5),
            titleTextField.centerXAnchor.constraint(equalTo: eventContainer.centerXAnchor),
            titleTextField.widthAnchor.constraint(equalToConstant: eventWidth),
            titleTextField.heightAnchor.constraint(lessThanOrEqualToConstant: 30)
        ]
        
        NSLayoutConstraint.activate(titleTextFieldConstraints)
        
        let titleContainerConstraints = [
            titleContainer.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -5),
            titleContainer.bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 3),
            titleContainer.leadingAnchor.constraint(equalTo: eventContainer.leadingAnchor, constant: 0),
            titleContainer.trailingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(titleContainerConstraints)
        
        let timeTextFieldConstraints = [
            timeTextField.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 5),
            //timeTextField.bottomAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 0),
            timeTextField.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor, constant: 0),
            timeTextField.heightAnchor.constraint(equalToConstant: 20),
            //timeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            //timeTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(timeTextFieldConstraints)
        
        let timeContainerConstraints = [
            timeContainer.topAnchor.constraint(equalTo: timeTextField.topAnchor, constant: -5),
            timeContainer.bottomAnchor.constraint(equalTo: timeTextField.bottomAnchor, constant: 5),
            timeContainer.leadingAnchor.constraint(equalTo: timeTextField.leadingAnchor, constant: -5),
            timeContainer.trailingAnchor.constraint(equalTo: timeTextField.trailingAnchor, constant: 5)
        ]
        
        NSLayoutConstraint.activate(timeContainerConstraints)
        
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: eventContainer.bounds.origin, size: CGSize(width: eventWidth, height: 90))
        gradientLayer.colors =
        [UIColor.black.withAlphaComponent(0.5).cgColor,UIColor.black.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.cornerRadius = 10
       //Use diffrent colors
        gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        eventContainer.layer.insertSublayer(gradientLayer, at: 0)
        
        let bodyTextFieldConstraints = [
            bodyTextField.bottomAnchor.constraint(equalTo: eventContainer.bottomAnchor, constant: -10),
            bodyTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bodyTextField.widthAnchor.constraint(equalToConstant: eventWidth - 20),
            bodyTextField.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
            //bodyTextField.heightAnchor.constraint(lessThanOrEqualToConstant: 100)
        ]
        
        NSLayoutConstraint.activate(bodyTextFieldConstraints)
        
        let bodyContainerConstraints = [
            bodyContainer.topAnchor.constraint(equalTo: bodyTextField.topAnchor, constant: -5),
            bodyContainer.bottomAnchor.constraint(equalTo: bodyTextField.bottomAnchor, constant: 10),
            bodyContainer.leadingAnchor.constraint(equalTo: bodyTextField.leadingAnchor, constant: -10),
            bodyContainer.trailingAnchor.constraint(equalTo: bodyTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(bodyContainerConstraints)
        
        let gradientLayer2:CAGradientLayer = CAGradientLayer()
        gradientLayer2.frame = CGRect(origin: bodyContainer.bounds.origin, size: CGSize(width: eventWidth, height: 115))
        gradientLayer2.colors =
        [UIColor.black.withAlphaComponent(0).cgColor,UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer2.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer2.cornerRadius = 10
       //Use diffrent colors
        gradientLayer2.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bodyContainer.layer.insertSublayer(gradientLayer2, at: 0)
        
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
            //self.eventContainer.layer.borderColor = UIColor.systemGreen.cgColor
            self.eventContainer.layer.borderWidth = 2
            //self.eventContainer.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            //self.currentNumber.backgroundColor = .clear
            //self.eventCap.backgroundColor = .clear
        } else if let currentNumberInt = Int(self.currentNumber.text ?? "5"), let eventCapInt = Int(self.eventCap.text ?? "15") {
            if currentNumberInt < eventCapInt {
                //self.eventContainer.layer.borderColor = UIColor.systemGreen.cgColor
                self.eventContainer.layer.borderWidth = 2
                //self.eventContainer.backgroundColor = .systemGreen.withAlphaComponent(0.15)
                //self.currentNumber.backgroundColor = .systemGreen
                //self.eventCap.backgroundColor = .systemGreen
            } else {
                //self.eventContainer.layer.borderColor = UIColor.systemRed.cgColor
                self.eventContainer.layer.borderWidth = 2
                //self.eventContainer.backgroundColor = .systemRed.withAlphaComponent(0.15)
                //self.currentNumber.backgroundColor = .systemRed
                //self.eventCap.backgroundColor = .systemRed
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
                        
                        if self.eventCap.text == "No Limit" {
                            isFull = false
                        } else if let eventCapInt = Int(self.eventCap.text ?? "0"), let currentNumberInt = Int(self.currentNumber.text ?? "0") {
                            if eventCapInt <= currentNumberInt {
                                isFull = false
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

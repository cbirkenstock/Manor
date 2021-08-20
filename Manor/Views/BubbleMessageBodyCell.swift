//
//  BubbleMessageBodyCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 6/29/21.
//

import UIKit
import Firebase

class BubbleMessageBodyCell: UITableViewCell {
    
    var documentID: String?
    var timeStamp: Double?
    let background = UIView()
    let bubbleView = UIView()
    let messageBody = UILabel()
    let venmoButton = UIButton()
    var incomingMessageConstraints: [NSLayoutConstraint]!
    var OutgoingMessageConstraints: [NSLayoutConstraint]!
    var groupStartConstraints: [NSLayoutConstraint]!
    var groupMiddleConstraints: [NSLayoutConstraint]!
    var groupEndConstraints: [NSLayoutConstraint]!
    var notOfGroupConstraints: [NSLayoutConstraint]!
    var emailLabelConstraints: [NSLayoutConstraint]!
    var bubbleViewConstraints: [NSLayoutConstraint]!
    var bubbleViewOfImageConstraints: [NSLayoutConstraint]!
    var messageImageViewContraints: [NSLayoutConstraint]!
    var incomingHeartCountLabelConstraints: [NSLayoutConstraint]!
    var incomingHeartIconButtonConstraints: [NSLayoutConstraint]!
    var outgoingHeartCountLabelConstraints: [NSLayoutConstraint]!
    var outgoingHeartIconButtonConstraints: [NSLayoutConstraint]!
    let emailLabel = UILabel()
    var venmoAmount: String = "0"
    var note: String = "Note"
    var venmoName: String = ""
    var isVenmoRequest: Bool = false
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    let groupChatMessagesRef = Database.database().reference().child("GroupChatMessages")


    
    
    var isIncoming: Bool! {
        didSet {
            bubbleView.layer.borderColor = isIncoming ? UIColor(named: K.BrandColors.purple)!.cgColor : UIColor.green.cgColor
            
            if isIncoming {
                NSLayoutConstraint.deactivate(OutgoingMessageConstraints)
                NSLayoutConstraint.activate(incomingMessageConstraints)
                
                let stringTimeStamp = self.timeStamp?.description
                let commaTimeStamp = stringTimeStamp?.replacingOccurrences(of: ".", with: ",")
                
                groupChatMessagesRef.child(self.documentID!).child("Messages").child("Message,\(commaTimeStamp!)").child("likes").observe(DataEventType.value, with: { DataSnapshot in
                    let likeNumber = DataSnapshot.value as? String ?? "0"
                    
                    if likeNumber == "0" {
                        self.heartCountLabel.isHidden = true
                        self.heartIconButton.isHidden = true
                    } else {
                        self.heartCountLabel.isHidden = false
                        self.heartIconButton.isHidden = false
                        
                        self.heartCountLabel.text = likeNumber
                    }
                })
                
                NSLayoutConstraint.deactivate(outgoingHeartCountLabelConstraints)
                NSLayoutConstraint.deactivate(outgoingHeartIconButtonConstraints)
                NSLayoutConstraint.activate(incomingHeartCountLabelConstraints)
                NSLayoutConstraint.activate(incomingHeartIconButtonConstraints)
            
            } else {
                NSLayoutConstraint.deactivate(incomingMessageConstraints)
                NSLayoutConstraint.activate(OutgoingMessageConstraints)
                
                let stringTimeStamp = self.timeStamp?.description
                let commaTimeStamp = stringTimeStamp?.replacingOccurrences(of: ".", with: ",")
                
                groupChatMessagesRef.child(self.documentID!).child("Messages").child("Message,\(commaTimeStamp!)").child("likes").observe(DataEventType.value, with: { DataSnapshot in
                    let likeNumber = DataSnapshot.value as? String ?? "0"
                    
                    if likeNumber == "0" {
                        self.heartCountLabel.isHidden = true
                        self.heartIconButton.isHidden = true
                    } else {
                        self.heartCountLabel.isHidden = false
                        self.heartIconButton.isHidden = false
                        
                        self.heartCountLabel.text = likeNumber
                    }
                })
                
                NSLayoutConstraint.deactivate(incomingHeartCountLabelConstraints)
                NSLayoutConstraint.deactivate(incomingHeartIconButtonConstraints)
                NSLayoutConstraint.activate(outgoingHeartIconButtonConstraints)
                NSLayoutConstraint.activate(outgoingHeartCountLabelConstraints)
            }
            
            if isVenmoRequest {
                
                contentView.addSubview(venmoButton)
                venmoButton.translatesAutoresizingMaskIntoConstraints = false
                venmoButton.backgroundColor = .clear
                venmoButton.addTarget(self, action: #selector(openVenmo), for: .touchUpInside)
                
                let venmoButtonConstraints = [
                    venmoButton.topAnchor.constraint(equalTo: messageBody.topAnchor, constant: -10),
                    venmoButton.bottomAnchor.constraint(equalTo: messageBody.bottomAnchor, constant: 10),
                    venmoButton.leadingAnchor.constraint(equalTo: messageBody.leadingAnchor, constant: -10),
                    venmoButton.trailingAnchor.constraint(equalTo: messageBody.trailingAnchor, constant: 10)
                ]
                
                NSLayoutConstraint.activate(venmoButtonConstraints)
                
                bubbleView.layer.borderColor = UIColor(named: "BrightBlue")?.cgColor
                bubbleView.removeGestureRecognizer(doubleTapGestureRecognizer)
            } else {
                bubbleView.addGestureRecognizer(doubleTapGestureRecognizer)
                //doubleTapGestureRecognizer.delegate = self
                //bubbleView.isUserInteractionEnabled = true
                //bubbleView.addGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }
    
    /*var isOfImage: Bool? {
     didSet {
     if isOfImage! {
     NSLayoutConstraint.deactivate(bubbleViewConstraints)
     NSLayoutConstraint.activate(bubbleViewOfImageConstraints)
     bubbleView.addSubview(messageImageView)
     NSLayoutConstraint.activate(messageImageViewContraints)
     } else {
     NSLayoutConstraint.deactivate(bubbleViewOfImageConstraints)
     NSLayoutConstraint.activate(bubbleViewConstraints)
     messageImageView.removeFromSuperview()
     NSLayoutConstraint.deactivate(messageImageViewContraints)
     }
     }
     }*/
    
    var groupPosition: String! {
        didSet {
            switch groupPosition {
            case "groupStart":
                NSLayoutConstraint.activate(groupStartConstraints)
                NSLayoutConstraint.deactivate(groupMiddleConstraints)
                NSLayoutConstraint.deactivate(groupEndConstraints)
                NSLayoutConstraint.deactivate(notOfGroupConstraints)
            case "groupMiddle":
                NSLayoutConstraint.deactivate(groupStartConstraints)
                NSLayoutConstraint.activate(groupMiddleConstraints)
                NSLayoutConstraint.deactivate(groupEndConstraints)
                NSLayoutConstraint.deactivate(notOfGroupConstraints)
            case "groupEnd":
                NSLayoutConstraint.deactivate(groupStartConstraints)
                NSLayoutConstraint.deactivate(groupMiddleConstraints)
                NSLayoutConstraint.activate(groupEndConstraints)
                NSLayoutConstraint.deactivate(notOfGroupConstraints)
            default:
                NSLayoutConstraint.deactivate(groupStartConstraints)
                NSLayoutConstraint.deactivate(groupMiddleConstraints)
                NSLayoutConstraint.deactivate(groupEndConstraints)
                NSLayoutConstraint.activate(notOfGroupConstraints)
            }
        }
    }
    
    
    var isGroupMessage: Bool! {
        didSet {
            if self.groupPosition == "groupStart" || self.groupPosition == "notOfGroup" {
                if  isGroupMessage && isIncoming {
                    addSubview(emailLabel)
                    emailLabel.translatesAutoresizingMaskIntoConstraints = false
                    emailLabel.frame.origin.y = bubbleView.frame.origin.y - 15
                    emailLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
                    emailLabel.textColor = .white
                    NSLayoutConstraint.activate(emailLabelConstraints)
                } else {
                    emailLabel.removeFromSuperview()
                    NSLayoutConstraint.deactivate(emailLabelConstraints)
                }
            } else {
                emailLabel.removeFromSuperview()
                NSLayoutConstraint.deactivate(emailLabelConstraints)
            }
        }
    }
    
    var heartIconButton: UIButton = {
        let heartIconButton = UIButton()
        heartIconButton.translatesAutoresizingMaskIntoConstraints = false
        let heartIconConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
        let heartImage = UIImage(systemName: "heart", withConfiguration: heartIconConfiguration)
        heartIconButton.setImage(heartImage, for: .normal)
        heartIconButton.tintColor = .systemPink
        heartIconButton.addTarget(self, action: #selector(messageDoubleTapped), for: .touchUpInside)
        return heartIconButton
    }()
    
    var heartCountLabel: UILabel = {
        let heartCountLabel = UILabel()
        heartCountLabel.translatesAutoresizingMaskIntoConstraints = false
        heartCountLabel.text = "5"
        heartCountLabel.textColor = .systemPink
        heartCountLabel.font = UIFont.systemFont(ofSize: 25)
        return heartCountLabel
    }()
    

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear//UIColor(named: K.BrandColors.backgroundBlack)
        self.isUserInteractionEnabled = true
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(messageDoubleTapped))
        
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        

        
        /*if self.imageURL != "" {
         print("crazy")
         DispatchQueue.global().async { [weak self] in
         let URL = URL(string: self!.imageURL)
         if let data = try? Data(contentsOf: URL!) {
         if let image = UIImage(data: data) {
         DispatchQueue.main.async {
         self?.messageImageView.image = image
         }
         }
         }
         }
         }*/
        
        /*addSubview(background)
         background.translatesAutoresizingMaskIntoConstraints = false
         background.backgroundColor = .clear//UIColor(named: K.BrandColors.backgroundBlack)*/
        
        
        contentView.addSubview(bubbleView)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = .clear
        bubbleView.layer.borderWidth = 2
        bubbleView.layer.borderColor = UIColor.green.cgColor
        bubbleView.layer.cornerRadius = 10
        
        
        contentView.addSubview(messageBody)
        messageBody.translatesAutoresizingMaskIntoConstraints = false
        messageBody.textColor = .white
        messageBody.numberOfLines = 0
        
        contentView.addSubview(heartIconButton)
        
        contentView.addSubview(heartCountLabel)
    
        //NSLayoutConstraint.activate(messageImageViewContraints)
        
        
        bubbleViewOfImageConstraints = [
            bubbleView.heightAnchor.constraint(equalToConstant: 300),
            bubbleView.widthAnchor.constraint(equalToConstant: 300),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ]
        
        /*let backgroundConstraints = [
         background.topAnchor.constraint(equalTo: topAnchor),
         background.bottomAnchor.constraint(equalTo: bottomAnchor),
         background.leadingAnchor.constraint(equalTo: leadingAnchor),
         background.trailingAnchor.constraint(equalTo: trailingAnchor)
         ]
         
         NSLayoutConstraint.activate(backgroundConstraints)*/
        
        /*let messageBodyConstraints = [
         messageBody.topAnchor.constraint(equalTo: topAnchor, constant: 20),
         messageBody.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
         ]
         
         NSLayoutConstraint.activate(messageBodyConstraints)*/
        
        bubbleViewConstraints = [
            bubbleView.topAnchor.constraint(equalTo: messageBody.topAnchor, constant: -10),
            bubbleView.bottomAnchor.constraint(equalTo: messageBody.bottomAnchor, constant: 10),
            bubbleView.leadingAnchor.constraint(equalTo: messageBody.leadingAnchor, constant: -10),
            bubbleView.trailingAnchor.constraint(equalTo: messageBody.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(bubbleViewConstraints)
        
        
        
        groupStartConstraints = [
            messageBody.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            messageBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11)
        ]
        
        groupMiddleConstraints = [
            messageBody.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            messageBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11)
        ]
        
        groupEndConstraints = [
            messageBody.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            messageBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25)
        ]
        
        notOfGroupConstraints = [
            messageBody.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            messageBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ]
        
        incomingMessageConstraints = [
            messageBody.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageBody.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -150)
        ]
        
        OutgoingMessageConstraints = [
            messageBody.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 150),
            messageBody.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ]
        
        emailLabelConstraints = [
            emailLabel.leadingAnchor.constraint(equalTo: messageBody.leadingAnchor, constant: 0)
        ]
        
        incomingHeartCountLabelConstraints = [
            heartCountLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0),
            heartCountLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 10),
            heartCountLabel.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        incomingHeartIconButtonConstraints = [
            heartIconButton.leadingAnchor.constraint(equalTo: heartCountLabel.trailingAnchor, constant: -5),
            heartIconButton.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0),
            heartIconButton.heightAnchor.constraint(equalToConstant: 40),
            heartIconButton.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        outgoingHeartIconButtonConstraints = [
            heartIconButton.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -5),
            heartIconButton.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0),
            heartIconButton.heightAnchor.constraint(equalToConstant: 40),
            heartIconButton.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        outgoingHeartCountLabelConstraints = [
            heartCountLabel.topAnchor.constraint(equalTo: heartIconButton.topAnchor, constant: 0),
            heartCountLabel.bottomAnchor.constraint(equalTo: heartIconButton.bottomAnchor, constant: 0),
            heartCountLabel.trailingAnchor.constraint(equalTo: heartIconButton.leadingAnchor, constant: 5)
        ]

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openVenmo() {
        print(self.venmoAmount)
        print(self.venmoName)
        let application = UIApplication.shared
        let appPath = "venmo://paycharge?txn=pay&recipients=\(self.venmoName)&amount=\(self.venmoAmount)&note=Thanks!"
        let appURL = URL(string: appPath)!
        application.open(appURL, options: [:]) { bool in
            print(bool)
        }
    }
    
    @objc func messageDoubleTapped() {
        let stringTimeStamp = self.timeStamp?.description
        let commaTimeStamp = stringTimeStamp?.replacingOccurrences(of: ".", with: ",")
        
        groupChatMessagesRef.child(self.documentID!).child("Messages").child("Message,\(commaTimeStamp!)").child("likes").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
            let likeNumber = DataSnapshot.value as? String ?? "0"
            let newLikeNumber = String(Int(likeNumber)! + 1)
            
            self.groupChatMessagesRef.child("\(self.documentID!)/Messages/Message,\(commaTimeStamp!)/likes").setValue(newLikeNumber)
            
            self.heartCountLabel.text = newLikeNumber
        }
    }
}

//
//  PictureMessageTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/7/21.
//

import UIKit

class PictureMessageTableViewCell: UITableViewCell {
    
    var imageURL: String = ""
    
    var messageImageViewContraints: [NSLayoutConstraint]!
    var incomingMessageConstraints: [NSLayoutConstraint]!
    var outgoingMessageConstraints: [NSLayoutConstraint]!
    var groupStartConstraints: [NSLayoutConstraint]!
    var groupMiddleConstraints: [NSLayoutConstraint]!
    var groupEndConstraints: [NSLayoutConstraint]!
    var notOfGroupConstraints: [NSLayoutConstraint]!
    var emailLabelConstraints: [NSLayoutConstraint]!
    var contentViewHeightConstraint: NSLayoutConstraint!
    var newMessageImageConstraints: [NSLayoutConstraint]!
    let emailLabel = UILabel()
    var newImageHeight: CGFloat = 0
    var newImageWidth: CGFloat = 0
    var sizeSet: Bool = false
    var messageViewHeightConstraint: NSLayoutConstraint!
    var messageViewWidthConstraint: NSLayoutConstraint!
    var messageImageViewHeightConstraint200: NSLayoutConstraint!
    var messageImageViewHeightConstraint250: NSLayoutConstraint!
    var messageImageViewHeightConstraint300: NSLayoutConstraint!
    var messageImageViewHeightConstraint350: NSLayoutConstraint!
    var messageImageViewHeightConstraint400: NSLayoutConstraint!
    var messageImageViewHeightConstraint450: NSLayoutConstraint!
    var messageImageViewHeightConstraint500: NSLayoutConstraint!
    var messageImageViewHeightConstraint550: NSLayoutConstraint!
    var messageImageViewHeightConstraint600: NSLayoutConstraint!
    var messageImageViewHeightConstraint650: NSLayoutConstraint!
    
    var imageHeight: CGFloat! {
        didSet {
            switch imageHeight! {
            case (0...200):
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint200.isActive = true
            case (200...250):
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint200.isActive = true
            case (250...300):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint300.isActive = true
            case (300...350):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint300.isActive = true
            case (350...400):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint400.isActive = true
            case (400...450):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint400.isActive = true
            case (450...500):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint500.isActive = true
            case (500...550):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint500.isActive = true
            case (550...600):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = true
            case (600...675):
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint300.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = true
            default:
                self.messageImageViewHeightConstraint200.isActive = false
                self.messageImageViewHeightConstraint400.isActive = false
                self.messageImageViewHeightConstraint500.isActive = false
                self.messageImageViewHeightConstraint600.isActive = false
                self.messageImageViewHeightConstraint300.isActive = true
            }
        }
    }
    
    /*var image: UIImage! {
        didSet {
            print(image.size.width)
            self.messageImageView.image = image
            print(image.size.width)
            self.messageImageView.sizeToFit()
        }
    }*/
    
    let messageImageView: UIImageView = {
        let messageImageView = UIImageView()
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.layer.cornerRadius = 15
        messageImageView.clipsToBounds = true
        messageImageView.contentMode = .scaleAspectFill
        return messageImageView
    }()
    
    var isIncoming: Bool! {
       didSet {
            if isIncoming {
             NSLayoutConstraint.deactivate(outgoingMessageConstraints)
             NSLayoutConstraint.activate(incomingMessageConstraints)
             } else {
             NSLayoutConstraint.deactivate(incomingMessageConstraints)
             NSLayoutConstraint.activate(outgoingMessageConstraints)
             }
        }
    }
    
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
                    emailLabel.frame.origin.y = messageImageView.frame.origin.y - 5
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .black
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(messageImageView)
        
        //contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 10000)
        
        //contentViewHeightConstraint.isActive = true
        
        /*if let constraints = newMessageImageConstraints {
            NSLayoutConstraint.deactivate(newMessageImageConstraints)
        }*/


        messageImageView.backgroundColor = .clear
        messageImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        
        
        messageImageViewHeightConstraint200 = messageImageView.heightAnchor.constraint(equalToConstant: 200)
        messageImageViewHeightConstraint250 = messageImageView.heightAnchor.constraint(equalToConstant: 250)
        messageImageViewHeightConstraint300 = messageImageView.heightAnchor.constraint(equalToConstant: 300)
        messageImageViewHeightConstraint350 = messageImageView.heightAnchor.constraint(equalToConstant: 350)
        messageImageViewHeightConstraint400 = messageImageView.heightAnchor.constraint(equalToConstant: 400)
        messageImageViewHeightConstraint450 = messageImageView.heightAnchor.constraint(equalToConstant: 450)
        messageImageViewHeightConstraint500 = messageImageView.heightAnchor.constraint(equalToConstant: 500)
        messageImageViewHeightConstraint550 = messageImageView.heightAnchor.constraint(equalToConstant: 550)
        messageImageViewHeightConstraint600 = messageImageView.heightAnchor.constraint(equalToConstant: 600)
        messageImageViewHeightConstraint650 = messageImageView.heightAnchor.constraint(equalToConstant: 650)
        
        groupStartConstraints = [
            messageImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            messageImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1)
        ]
        
        groupMiddleConstraints = [
            messageImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            messageImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1)
        ]
        
        groupEndConstraints = [
            messageImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            messageImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ]
        
        notOfGroupConstraints = [
            messageImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            messageImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ]
        
        incomingMessageConstraints = [
            messageImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            //messageImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -150)
        ]
        
        outgoingMessageConstraints = [
            //messageImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 150),
            messageImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ]
        
        emailLabelConstraints = [
            emailLabel.leadingAnchor.constraint(equalTo: messageImageView.leadingAnchor, constant: 0)
        ]
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

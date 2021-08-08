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
    var imageHeight: CGFloat = 0
    var newImageHeight: CGFloat = 0
    var newImageWidth: CGFloat = 0
    var sizeSet: Bool = false
    var messageViewHeightConstraint: NSLayoutConstraint!
    var messageViewWidthConstraint: NSLayoutConstraint!
    
    var imageWidth: CGFloat! {
        didSet {
            //contentViewHeightConstraint.isActive = false
            
            //NSLayoutConstraint.deactivate(messageImageViewContraints)
            
//            newMessageImageConstraints = [
//                messageImageView.heightAnchor.constraint(equalToConstant: 1000),
//                messageImageView.widthAnchor.constraint(equalToConstant: self.imageWidth)
//            ]
//
//            NSLayoutConstraint.activate(newMessageImageConstraints)
            //messageImageView.heightAnchor.constraint(equalToConstant: self.imageHeight).isActive = true
            //messageImageView.widthAnchor.constraint(equalToConstant: self.imageWidth!).isActive = true
            
            /*messageViewHeightConstraint.isActive = true
             messageViewWidthConstraint.isActive = true*/
            
            //messageImageView.heightAnchor.constraint(equalToConstant: self.imageHeight).isActive = true
            //messageImageView.widthAnchor.constraint(equalToConstant: self.imageWidth).isActive = true
        }
    }
    
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
        
        contentView.addSubview(messageImageView)
        
        //contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 10000)
        
        //contentViewHeightConstraint.isActive = true
        
        if let constraints = newMessageImageConstraints {
            NSLayoutConstraint.deactivate(newMessageImageConstraints)
        }

        messageImageViewContraints = [
            //messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            //messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10)
            messageImageView.heightAnchor.constraint(equalToConstant: 400),
            messageImageView.widthAnchor.constraint(equalToConstant: 350)
        ]

        NSLayoutConstraint.activate(messageImageViewContraints)
        
        groupStartConstraints = [
            messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            messageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ]
        
        groupMiddleConstraints = [
            messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            messageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ]
        
        groupEndConstraints = [
            messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            messageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ]
        
        notOfGroupConstraints = [
            messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            messageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ]
        
        incomingMessageConstraints = [
            messageImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -150)
        ]
        
        outgoingMessageConstraints = [
            messageImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 150),
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

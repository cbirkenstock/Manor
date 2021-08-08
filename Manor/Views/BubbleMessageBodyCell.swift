//
//  BubbleMessageBodyCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 6/29/21.
//

import UIKit

class BubbleMessageBodyCell: UITableViewCell {
    
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
    let emailLabel = UILabel()
    var venmoAmount: String = "0"
    var note: String = "Note"
    var venmoName: String = ""
    var isVenmoRequest: Bool = false
    
    
    var isIncoming: Bool! {
        didSet {
            bubbleView.layer.borderColor = isIncoming ? UIColor(named: K.BrandColors.purple)!.cgColor : UIColor.green.cgColor
            
            if isIncoming {
                NSLayoutConstraint.deactivate(OutgoingMessageConstraints)
                NSLayoutConstraint.activate(incomingMessageConstraints)
            } else {
                NSLayoutConstraint.deactivate(incomingMessageConstraints)
                NSLayoutConstraint.activate(OutgoingMessageConstraints)
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
    

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear//UIColor(named: K.BrandColors.backgroundBlack)
        self.isUserInteractionEnabled = true
        
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
}

//
//  TestTwoCollectionViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/19/21.
//
//
//  TestCollectionViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/31/21.
//

import UIKit

class TestTwoCollectionViewCell: UICollectionViewCell {
    
    var documentID: String = ""
    var members: [String] = []
    var contactImageViewConstraints: [NSLayoutConstraint]!
    let imageCache = NSCache<NSString, AnyObject>()
    var bigContactImageViewConstraints: [NSLayoutConstraint]!
    var smallContactImageViewConstraints: [NSLayoutConstraint]!
    
    /*var isSearchName: Bool! {
        didSet {
            if isSearchName {
                NSLayoutConstraint.deactivate(contactImageViewConstraints)
                
                let newContactImageViewConstraints = [
                    contactImageView.topAnchor.constraint(equalTo: indicatorCircle.topAnchor, constant: 0),
                    contactImageView.bottomAnchor.constraint(equalTo: indicatorCircle.bottomAnchor, constant: 0),
                    contactImageView.leadingAnchor.constraint(equalTo: indicatorCircle.leadingAnchor, constant: 0),
                    contactImageView.trailingAnchor.constraint(equalTo: indicatorCircle.trailingAnchor, constant: 0)
                ]
                
                NSLayoutConstraint.activate(newContactImageViewConstraints)
                
                contactImageView.layer.cornerRadius = (self.frame.width - 20)/2
            }
        }
    }*/
    
    /*var indicatorCircle: UIView = {
        let indicatorCircle = UIView()
        indicatorCircle.translatesAutoresizingMaskIntoConstraints = false
        indicatorCircle.backgroundColor = UIColor(named: "LightBlue")
        return indicatorCircle
    }()*/
    
    var contactImageView: UIImageView = {
        let contactImageView = UIImageView()
        contactImageView.translatesAutoresizingMaskIntoConstraints = false
        //contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
        contactImageView.clipsToBounds = true
        return contactImageView
    }()
    
    var contactFirstName: UILabel = {
        let contactLabel = UILabel()
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.textColor = .white
        contactLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        contactLabel.textAlignment = .center
        return contactLabel
    }()
    
    var contactLastName: UILabel = {
        let contactLabel = UILabel()
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.textColor = .white
        contactLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        contactLabel.textAlignment = .center
        return contactLabel
    }()
    
    /*var lastMessageLabel: UILabel = {
        let lastMessageLabel = UILabel()
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.textColor = .white
        lastMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lastMessageLabel.textAlignment = .center
        return lastMessageLabel
    }()*/
    
    /*var isMainFour: Bool! {
     didSet {
     if isMainFour {
     NSLayoutConstraint.deactivate(smallIndicatorCircleConstraints)
     NSLayoutConstraint.activate(bigIndicatorCircleConstraints)
     
     indicatorCircle.layer.cornerRadius = (self.frame.width - 20)/2
     contactImageView.layer.cornerRadius = (self.frame.width - 30)/2
     
     lastMessageLabel.isHidden = false
     } else {
     NSLayoutConstraint.deactivate(bigIndicatorCircleConstraints)
     NSLayoutConstraint.activate(smallIndicatorCircleConstraints)
     
     indicatorCircle.layer.cornerRadius = (UIScreen.main.bounds.width/3 - 30)/2
     contactImageView.layer.cornerRadius = (UIScreen.main.bounds.width/3 - 30)/2
     
     lastMessageLabel.isHidden = true
     }
     }
     }*/
    
    var isBig: Bool! {
        didSet {
            if isBig {
                NSLayoutConstraint.deactivate(smallContactImageViewConstraints)
                NSLayoutConstraint.activate(bigContactImageViewConstraints)
                self.contactFirstName.font = UIFont.systemFont(ofSize: 21, weight: .bold)
                contactImageView.layer.cornerRadius = (UIScreen.main.bounds.width/3 - 30)/2
            } else {
                NSLayoutConstraint.deactivate(bigContactImageViewConstraints)
                NSLayoutConstraint.activate(smallContactImageViewConstraints)
                self.contactFirstName.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                contactImageView.layer.cornerRadius = (UIScreen.main.bounds.width/5 - 20)/2
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = .green
        
        self.addSubview(contactImageView)
        self.addSubview(contactFirstName)
        self.addSubview(contactLastName)
        
        let bigCellWidth = UIScreen.main.bounds.width/3 - 10
        let bigCellHeight = bigCellWidth/0.7
        let bigIconWidth = bigCellWidth - 20
        let bigBottomConstraint = ((bigCellHeight - bigIconWidth - 5) * -1)
        
        bigContactImageViewConstraints = [
            contactImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            contactImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            contactImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bigBottomConstraint),
            contactImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
        ]
        
        let smallCellWidth = UIScreen.main.bounds.width/5 - 10
        let smallCellHeight = 90
        let smallIconWidth = smallCellWidth - 10
        let smallBottomConstraint = ((smallCellHeight - Int(smallIconWidth) - 5) * -1)
        
        
        smallContactImageViewConstraints = [
            contactImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            contactImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            contactImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: CGFloat(smallBottomConstraint) - 5),
            contactImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
        ]
        
        
        let contactFirstNameConstraints = [
            contactFirstName.topAnchor.constraint(equalTo: contactImageView.bottomAnchor, constant: 5),
            contactFirstName.heightAnchor.constraint(equalToConstant: 25),
            contactFirstName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            contactFirstName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(contactFirstNameConstraints)
        
        let contactLastNameConstraints = [
            contactLastName.topAnchor.constraint(equalTo: contactFirstName.bottomAnchor, constant: 0),
            contactLastName.heightAnchor.constraint(equalToConstant: 25),
            contactLastName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            contactLastName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(contactLastNameConstraints)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

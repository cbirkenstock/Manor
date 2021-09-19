//
//  TestCollectionViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/31/21.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {
    
    var eventDescription: String = ""
    var eventDate: String = ""
    var eventTime: String = ""
    
    var documentID: String = ""
    var members: [String] = []
    var contactImageViewConstraints: [NSLayoutConstraint]!
    let imageCache = NSCache<NSString, AnyObject>()
    var bigIndicatorCircleConstraints: [NSLayoutConstraint]!
    var smallIndicatorCircleConstraints: [NSLayoutConstraint]!


    var profileImageUrl: String! {
        didSet {
            /*if profileImageUrl == "default" {
                contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            } else {
                contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
                contactImageView.backgroundColor = .gray
                indicatorCircle.backgroundColor = .clear
                
                if let cachedImage = self.imageCache.object(forKey: self.profileImageUrl! as NSString) {
                    self.contactImageView.image = cachedImage as? UIImage
                } else {
                    DispatchQueue.global().async { [weak self] in
                        let URL = URL(string: self!.profileImageUrl)
                        if let data = try? Data(contentsOf: URL!) {
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self!.imageCache.setObject(image, forKey: self!.profileImageUrl as NSString)
                                    self?.contactImageView.image = image
                                    if self?.hasUnreadMessages == true {
                                        self?.indicatorCircle.backgroundColor = UIColor(named: "LightBlue")
                                    }
                                }
                            }
                        }
                    }
                }
            }*/
        }
    }
    
    var isSearchName: Bool! {
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
    }
    
    var indicatorCircle: UIView = {
        let indicatorCircle = UIView()
        indicatorCircle.translatesAutoresizingMaskIntoConstraints = false
        indicatorCircle.backgroundColor = UIColor(named: "LightBlue")
        return indicatorCircle
    }()
    
    var contactImageView: UIImageView = {
        let contactImageView = UIImageView()
        contactImageView.translatesAutoresizingMaskIntoConstraints = false
        //contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
        contactImageView.clipsToBounds = true
        return contactImageView
    }()
    
    var contactName: UILabel = {
        let contactLabel = UILabel()
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.textColor = .white
        contactLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        contactLabel.textAlignment = .center
        return contactLabel
    }()
    
    var lastMessageLabel: UILabel = {
        let lastMessageLabel = UILabel()
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.textColor = .white
        lastMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lastMessageLabel.textAlignment = .center
        return lastMessageLabel
    }()
    
    var hasUnreadMessages: Bool! {
        didSet {
            contactImageView.image = nil
            indicatorCircle.backgroundColor = .clear
            indicatorCircle.backgroundColor = hasUnreadMessages ? UIColor(named: "LightBlue") : .clear
        }
    }
    
    var isMainFour: Bool! {
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
                
                indicatorCircle.layer.cornerRadius = (UIScreen.main.bounds.width/3 - 20)/2
                contactImageView.layer.cornerRadius = (UIScreen.main.bounds.width/3 - 30)/2
                
                lastMessageLabel.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(indicatorCircle)
        indicatorCircle.addSubview(contactImageView)
        self.addSubview(contactName)
        self.addSubview(lastMessageLabel)
        
        contactImageViewConstraints = [
            contactImageView.topAnchor.constraint(equalTo: indicatorCircle.topAnchor, constant: 5),
            contactImageView.bottomAnchor.constraint(equalTo: indicatorCircle.bottomAnchor, constant: -5),
            contactImageView.leadingAnchor.constraint(equalTo: indicatorCircle.leadingAnchor, constant: 5),
            contactImageView.trailingAnchor.constraint(equalTo: indicatorCircle.trailingAnchor, constant: -5)
        ]
        
        NSLayoutConstraint.activate(contactImageViewConstraints)
        
        let contactNameConstraints = [
            contactName.topAnchor.constraint(equalTo: indicatorCircle.bottomAnchor, constant: 5),
            contactName.heightAnchor.constraint(equalToConstant: 25),
            contactName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            contactName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(contactNameConstraints)
        
        let lastMessageConstraints = [
            lastMessageLabel.topAnchor.constraint(equalTo: contactName.bottomAnchor, constant: 5),
            lastMessageLabel.heightAnchor.constraint(equalToConstant: 20),
            lastMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            lastMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ]
        
        NSLayoutConstraint.activate(lastMessageConstraints)
        
        indicatorCircle.layer.cornerRadius = (self.frame.width - 20)/2
        contactImageView.layer.cornerRadius = (self.frame.width - 30)/2
        
        let bigCellWidth = UIScreen.main.bounds.width/2 - 10
        let bigCellHeight = bigCellWidth/0.8244
        let bigIconWidth = bigCellWidth - 20
        let bigBottomConstraint = ((bigCellHeight - bigIconWidth - 5) * -1)
        
        bigIndicatorCircleConstraints = [
            indicatorCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            indicatorCircle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            indicatorCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bigBottomConstraint),
            indicatorCircle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            //indicatorCircle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        /*bigIndicatorCircleConstraints = [
            indicatorCircle.widthAnchor.constraint(equalToConstant: self.frame.width - 20),
            indicatorCircle.heightAnchor.constraint(equalToConstant: self.frame.width - 20),
            indicatorCircle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            indicatorCircle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]*/
        
        let smallCellWidth = UIScreen.main.bounds.width/3 - 10
        let smallCellHeight = smallCellWidth/0.875
        let smallIconWidth = smallCellWidth - 10
        let smallBottomConstraint = ((smallCellHeight - smallIconWidth - 5) * -1)

        
        smallIndicatorCircleConstraints = [
            //indicatorCircle.widthAnchor.constraint(equalToConstant: width),
            //indicatorCircle.heightAnchor.constraint(equalToConstant: width),
            indicatorCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            indicatorCircle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            indicatorCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: smallBottomConstraint),
            indicatorCircle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            //indicatorCircle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

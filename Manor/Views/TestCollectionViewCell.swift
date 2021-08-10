//
//  TestCollectionViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/31/21.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {
    
    var documentID: String = ""
    var members: [String] = []
    var contactImageViewConstraints: [NSLayoutConstraint]!
    let imageCache = NSCache<NSString, AnyObject>()
    
    var profileImageUrl: String! {
        didSet {
            if profileImageUrl == "default" {
                contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
            } else {
                //contactImageView.image = #imageLiteral(resourceName: "AbstractPainting")
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
            }
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(indicatorCircle)
        indicatorCircle.addSubview(contactImageView)
        self.addSubview(contactName)
        self.addSubview(lastMessageLabel)
        
        let indicatorCircleConstraints = [
            indicatorCircle.widthAnchor.constraint(equalToConstant: self.frame.width - 20 ),
            indicatorCircle.heightAnchor.constraint(equalToConstant: self.frame.width - 20 ),
            indicatorCircle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            indicatorCircle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(indicatorCircleConstraints)
        
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
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

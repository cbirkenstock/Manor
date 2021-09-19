//
//  MemberTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/11/21.
//

import UIKit
import Firebase
import Amplify
import AmplifyPlugins

class MemberTableViewCell: UITableViewCell {
    
    let background = UIView()
    let contactName = UILabel()
    var pushMessageUID: String = ""
    var specificTextFieldText: String = ""
    let specificTextField = UITextField()
    var contactEmail: String?
    let usersRef = Database.database().reference().child("users")
    var contactNameConstraints: [NSLayoutConstraint] = []
    var profileImageViewConstraints: [NSLayoutConstraint] = []
    var defaultContactNameConstraints: [NSLayoutConstraint] = []
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.clipsToBounds = true
        profileImageView.image = #imageLiteral(resourceName: "NewContactIcon")
        profileImageView.layer.cornerRadius = 42/2
        return profileImageView
    }()
    
    var isContact: Bool! {
        didSet {
            if isContact {
                
                NSLayoutConstraint.deactivate(defaultContactNameConstraints)
                NSLayoutConstraint.activate(contactNameConstraints)
            
                contentView.addSubview(profileImageView)
                
                profileImageViewConstraints = [
                    profileImageView.topAnchor.constraint(equalTo: background.topAnchor, constant: 1),
                    profileImageView.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -1),
                    profileImageView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 1),
                    profileImageView.widthAnchor.constraint(equalToConstant: 42)
                ]
                
                NSLayoutConstraint.activate(profileImageViewConstraints)
            
                self.profileImageView.image = nil
                
                if let commaEmail = self.contactEmail?.replacingOccurrences(of: ".", with: ",") {
                    usersRef.child(commaEmail).child("profileImageUrl").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                        if let postString = DataSnapshot.value as? String {
                            
                            self.downloadImage(UrlString: postString) { image in
                                self.profileImageView.image = image
                            }
                        } else {
                            self.profileImageView.image = #imageLiteral(resourceName: "AbstractPainting")
                        }
                    }
                }
                
            } else {
                NSLayoutConstraint.deactivate(contactNameConstraints)
                NSLayoutConstraint.deactivate(profileImageViewConstraints)
                profileImageView.removeFromSuperview()
                SetUpNormalConstraints()
            }
            
            
        }
    }
    
    var isSettingsButton: Bool! {
        didSet {
            if isSettingsButton {
                self.addSubview(specificTextField)
                specificTextField.translatesAutoresizingMaskIntoConstraints = false
                specificTextField.textAlignment = .right
                specificTextField.textColor = .white
                specificTextField.font = UIFont.systemFont(ofSize: 22)
                specificTextField.text = self.specificTextFieldText
                specificTextField.isUserInteractionEnabled = false
                
                let specificTextFieldConstraints = [
                    specificTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
                    specificTextField.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
                    specificTextField.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
                    specificTextField.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
                ]
                
                NSLayoutConstraint.activate(specificTextFieldConstraints)
            } else {
                specificTextField.removeFromSuperview()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.cornerRadius = 10
        background.backgroundColor = UIColor(named: K.BrandColors.navigationBarGray)
        
        
        addSubview(contactName)
        contactName.translatesAutoresizingMaskIntoConstraints = false
        contactName.textAlignment = .left
        contactName.textColor = .white
        contactName.font = UIFont.systemFont(ofSize: 22)
        //contactName.numberOfLines = 0
        
        let backgroundConstraints = [
            background.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            background.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            background.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(backgroundConstraints)
        
        
        contactNameConstraints = [
            contactName.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 52),
            contactName.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
            contactName.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
            contactName.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
        ]
        
        defaultContactNameConstraints = [
            contactName.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            contactName.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
            contactName.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
            contactName.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
        ]
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func SetUpNormalConstraints() {
        NSLayoutConstraint.deactivate(contactNameConstraints)
        NSLayoutConstraint.activate(defaultContactNameConstraints)
    }
    
    func downloadImage(UrlString: String, completion: @escaping (UIImage) -> ()) {
        Amplify.Storage.downloadData(key: UrlString) { result in
            switch result {
            case .success(let data):
                print("Success downloading image", data)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            case .failure(let error):
                print("failure downloading image", error)
            }
        }
    }
    
    
    
    
    /*override func awakeFromNib() {
     super.awakeFromNib()
     // Initialization code
     }
     
     override func setSelected(_ selected: Bool, animated: Bool) {
     super.setSelected(selected, animated: animated)
     
     // Configure the view for the selected state
     }*/
    
}

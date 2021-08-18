//
//  MemberTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/11/21.
//

import UIKit
import Firebase

class MemberTableViewCell: UITableViewCell {
    
    let background = UIView()
    let contactName = UILabel()
    var pushMessageUID: String = ""
    var specificTextFieldText: String = ""
    let specificTextField = UITextField()
    var contactEmail: String?
    let usersRef = Database.database().reference().child("users")
    
    var isContact: Bool! {
        didSet {
            if isContact {
                let contactNameConstraints = [
                    contactName.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
                    contactName.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 52),
                    contactName.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
                    contactName.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
                ]
                
                NSLayoutConstraint.activate(contactNameConstraints)
                
                let profileImageView: UIImageView = {
                    let profileImageView = UIImageView()
                    profileImageView.translatesAutoresizingMaskIntoConstraints = false
                    profileImageView.clipsToBounds = true
                    profileImageView.image = #imageLiteral(resourceName: "NewContactIcon")
                    profileImageView.layer.cornerRadius = 42/2
                    return profileImageView
                }()
                
                contentView.addSubview(profileImageView)
                
                let profileImageViewConstraints = [
                    profileImageView.topAnchor.constraint(equalTo: background.topAnchor, constant: 1),
                    profileImageView.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -1),
                    profileImageView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 1),
                    profileImageView.widthAnchor.constraint(equalToConstant: 42)
                ]
                
                NSLayoutConstraint.activate(profileImageViewConstraints)
                
                if let commaEmail = self.contactEmail?.replacingOccurrences(of: ".", with: ",") {
                    usersRef.child(commaEmail).child("profileImageUrl").observeSingleEvent(of: DataEventType.value) { DataSnapshot in
                        let postString = DataSnapshot.value as! String
                        
                        print("postString")
                        print(postString)
                        
                        
                        self.downloadImage(UrlString: postString) { image in
                            profileImageView.image = image
                        }
                    }
                }
                
            } else {
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
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .black
        
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
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func SetUpNormalConstraints() {
        let contactNameConstraints = [
            contactName.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            contactName.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
            contactName.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
            contactName.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(contactNameConstraints)
    }
    
    func downloadImage(UrlString: String, completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async { [weak self] in
            let URL = URL(string: UrlString)
            if let data = try? Data(contentsOf: URL!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
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
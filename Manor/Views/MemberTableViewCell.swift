//
//  MemberTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 7/11/21.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    let background = UIView()
    let contactName = UILabel()
    var pushMessageUID: String = ""

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
        contactName.font = UIFont.systemFont(ofSize: 25)
        //contactName.numberOfLines = 0 
        
        let backgroundConstraints = [
            background.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            background.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            background.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(backgroundConstraints)
        
        let contactNameConstraints = [
            contactName.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            contactName.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
            contactName.topAnchor.constraint(equalTo: background.topAnchor, constant: 20),
            contactName.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(contactNameConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

//
//  ContactCollectionViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/25/21.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var defaultContactIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var documentID: String = ""
    var members: [String] = []
    var profileImageUrl: String = ""
}

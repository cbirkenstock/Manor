//
//  ContactCellTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/15/21.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var defaultContactIcon: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    
    var email: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  RegularMessageBody.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/15/21.
//

import UIKit

class RegularMessageBody: UITableViewCell {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageBodyView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readbutton: UIButton!
    var pushMessageUID: String = ""
    
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.backgroundColor = .black
        profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleToFill
        self.profileImageView.image = UIImage(named: "AbstractPainting")
        self.profileImageView.layer.cornerRadius = 35/2
        
        self.readbutton.layer.cornerRadius = 8
        self.readbutton.layer.shadowColor = UIColor(named: "WarmBlack")?.cgColor
        self.readbutton.layer.shadowOpacity = 0.5
        
        /*getMessageBodyWidth { width in
            self.messageBodyViewWidth.constant = width + 20
        }*/
        
        
        /*self.messageBodyViewWidth.constant = self.messageBody.bounds.width + 20*/
        
        /*self.messageBodyView.layer.cornerRadius = self.messageBodyView.bounds.height/2
        self.messageBodyView.layer.borderWidth = 2
        self.messageBodyView.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        self.messageBodyView.layer.backgroundColor = UIColor(named: K.BrandColors.backgroundBlack)?.cgColor*/
        
    }
    

    /*@IBAction func readButtonPressed(_ sender: UIButton) {
        print(self.pushMessageUID)
    }*/
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        
        // Configure the view for the selected state
    }

    /*func getMessageBodyWidth(setMessageBodyViewWidth: (CGFloat) -> ()) {
        

        setMessageBodyViewWidth(width)
    }*/
    
}

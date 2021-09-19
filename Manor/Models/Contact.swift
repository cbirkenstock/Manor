//
//  Contact.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/13/21.
//

import Foundation
import UIKit

struct Contact: Equatable {
    
    let email: String
    let fullName: String
    var timeStamp: Double = 0.0
    var members: [String] = []
    var lastMessage: String = ""
    var badgeCount: Int = 0
    var profileImageUrl: String = ""
    var image: UIImage? = nil
    var event: Event? = nil
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return
            lhs.email == rhs.email &&
            lhs.fullName == lhs.fullName
    }
    
}


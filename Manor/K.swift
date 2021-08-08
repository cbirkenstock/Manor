//
//  K.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/28/21.
//

struct K {
    struct Segues {
        static let loginSegue = "toLogInView"
        static let signInSegue = "toSignUpView"
        static let ContactPageViewSegue = "toContactPageView"
        static let newGroupMessageSegue = "toNewGroupMessageView"
        static let newDirectMessageSegue = "toNewDirectMessageView"
        static let DirectMessageChatSegue = "toChatView"
        static let GroupChatSegue = "toGroupChatView"
    }
    
    struct BrandColors {
        static let purple = "BrandPurpleColor"
        static let red = "BrandRedColor"
        static let navigationBarGray = "NavigationBarGray"
        static let backgroundBlack = "BackgroundBlack"
    }
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}


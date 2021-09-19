//
//  Message.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/15/21.
//

import Foundation

struct Message{
    let messageSender: String
    let messageBody: String?
    let timeStamp: Double
    let pushMessageUID: String?
    var imageURL: String? = ""
    var venmoName: String = ""
    var messageSenderNickName: String? = ""
    var messageSenderChatImage: String? = ""
    var event: Event? = nil
    var imageWidth: Double = 0
    var imageHeight: Double = 0
}

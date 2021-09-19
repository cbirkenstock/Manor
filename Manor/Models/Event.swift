//
//  Event.swift
//  Manor
//
//  Created by Colin Birkenstock on 9/2/21.
//

import Foundation

struct Event {
    let title: String
    let description: String
    var date: String = ""
    var time: String = ""
    let documentID: String?
    var eventCap: String = "No Limit"
    var currentNumber: String = "0"
}

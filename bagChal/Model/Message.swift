//
//  Message.swift
//  bagChal
//
//  Created by Sabir Thapa on 10/01/2024.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var senderId: String
    var text: String
    var recieved: Bool
    var timestamp: Date
}


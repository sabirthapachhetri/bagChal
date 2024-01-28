//
//  MPGameMove.swift
//  bagChal
//
//  Created by Sabir Thapa on 22/01/2024.
//

import Foundation

struct MPGameMove: Codable {
    enum Action: Int, Codable {
        case start, move, reset, end
    }
    let action: Action
    let playerName: String?
    let move: Move? 
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

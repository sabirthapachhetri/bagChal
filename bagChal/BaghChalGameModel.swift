//
//  GameModel.swift
//  bagChal
//
//  Created by Sabir Thapa on 22/01/2024.
//

import SwiftUI

enum GameType {
    case single, bot, peer, undetermined
    
    var description: String {
        switch self {
        case .single:
            return "Share your iPhone/iPad and play against a friend."
        case .bot:
            return "Play against this iPhone/iPad."
        case .peer:
            return "Invite someone near you who has this app running to play."
        case .undetermined:
            return ""
        }
    }
}

struct Player {
    let gamePiece: GamePiece
    var name: String
    var moves: [Int] = []
    var isCurrent = false

    // Modified to method with parameters
    func isWinner(baghsTrapped: Int, goatsCaptured: Int) -> String {
        if baghsTrapped == 4 {
            return "G"
        } else if goatsCaptured >= 5 {
            return "B"
        } else {
            return ""
        }
    }
}

enum GamePiece: String {
    case tiger, goat
}


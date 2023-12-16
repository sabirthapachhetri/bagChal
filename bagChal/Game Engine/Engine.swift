//
//  Engine.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation

class Engine {
    var depth: Int

    init(depth: Int = 5) {
        self.depth = depth
    }
    
    let INF: Double = Double.greatestFiniteMagnitude

    func staticEvaluation(for game: BaghChalGame) -> Double {
        let end = game.isGameOver
        if !end {
            return 10 * Double(game.goatsCaptured) - 10 * Double(game.baghsTrapped)
        }

        let winner = game.winner()
        switch winner {
        case "G": // Assuming "G" stands for goats winning
            return INF
        case "B": // Assuming "B" stands for baghs winning
            return -INF
        default: // In case of a draw or no winner yet
            return 0
        }
    }

    // The minimax algorithm with alpha-beta pruning
    func minimax(game: BaghChalGame, depth: Int, alpha: Double, beta: Double, maximizingPlayer: Bool) -> Double {
        if depth == 0 || game.isGameOver {
            return staticEvaluation(for: game)
        }

        var alpha = alpha
        var beta = beta

        if maximizingPlayer {
            var maxEval = -Double.infinity
            for move in game.possibleMoves() {
                let evaluation = minimax(game: game.simulateMove(move), depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
                maxEval = max(maxEval, evaluation)
                alpha = max(alpha, evaluation)
                if beta <= alpha {
                    break
                }
            }
            return maxEval
        } else {
            var minEval = Double.infinity
            for move in game.possibleMoves() {
                let evaluation = minimax(game: game.simulateMove(move), depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
                minEval = min(minEval, evaluation)
                beta = min(beta, evaluation)
                if beta <= alpha {
                    break
                }
            }
            return minEval
        }
    }
}

//
//  Engine.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation

class Engine {
    var depth: Int

    init(depth: Int = 3) {
        self.depth = depth
    }
    
    let INF: Double = Double.greatestFiniteMagnitude

    func staticEvaluation(for game: BaghChalGame) -> Double {
        // Check for end game conditions first
        let end = game.isGameOver
        if end {
            let winner = game.winner()
            switch winner {
            case "G":
                return INF
            case "B":
                return -INF
            default:
                return 0
            }
        }

        var score = 0.0
        // Adjust these weights as necessary
        let goatWeight = 10.0
        let tigerWeight = 10.0
        let mobilityWeight = 5.0
        let captureWeight = 200.0

        // Calculate score based on captured goats and trapped tigers
        score += goatWeight * Double(game.goatsCaptured)
        score -= tigerWeight * Double(game.baghsTrapped)

        // Evaluate mobility (how many moves are available for tigers)
        let tigerMobility = game.tigerPositions.map { position -> Int in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.count
        }.reduce(0, +)
        score += mobilityWeight * Double(tigerMobility)

        // Evaluate capture potential
        let capturePotential = game.tigerPositions.contains { position -> Bool in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.contains { move in game.canTigerCapture(from: game.convertToCGPoint(move.from), to: game.convertToCGPoint(move.to)) }
        }
        if capturePotential {
            score += captureWeight
        }
        
        return score
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
    
    func deepCopy() -> Engine {
        return Engine(depth: self.depth)
    }
}

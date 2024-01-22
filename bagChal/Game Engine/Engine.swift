//
//  Engine.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation

class Engine {
    var depth: Int

    init(depth: Int = 1) {
        self.depth = depth
    }
    
    let INF: Double = Double.greatestFiniteMagnitude

    func staticEvaluation(for game: BaghChalGame) -> Double {
        // Endgame conditions
        if game.isGameOver {
            switch game.winner() {
            case "G": return INF // Goats win
            case "B": return -INF // Tigers win
            default: break
            }
        }

        var score = 0.0

        // Scoring weights
        let goatWeight = 10.0
        let tigerWeight = 15.0
        let mobilityWeight = 5.0
        let captureWeight = 200.0
        let goatSafetyWeight = 5.0
        let tigerThreatWeight = 10.0

        // Goat captures
        score -= goatWeight * Double(game.goatsCaptured)

        // Tiger traps
        score += tigerWeight * Double(game.baghsTrapped)

        // Tiger mobility
        let tigerMobility = game.tigerPositions.map { position -> Int in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.count
        }.reduce(0, +)
        score += mobilityWeight * Double(tigerMobility)

        // Tiger capture potential
        let capturePotential = game.tigerPositions.contains { position -> Bool in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.contains { move in game.canTigerCapture(from: game.convertToCGPoint(move.from), to: game.convertToCGPoint(move.to)) }
        }
        if capturePotential {
            score += captureWeight
        }

        // Goat safety and tiger threat
        for goatPosition in game.goatPositions {
            let goatGridPoint = game.convertToGridPoint(goatPosition)
            if game.isGoatSafe(at: goatGridPoint) {
                score += goatSafetyWeight
            }
            if game.isGoatUnderThreat(at: goatGridPoint) {
                score -= tigerThreatWeight
            }
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

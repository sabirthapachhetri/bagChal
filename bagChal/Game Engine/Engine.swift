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
            return evaluateEndgame(for: game)
        }

        var score = 0.0

        // Evaluations
        score -= evaluateGoatCaptures(for: game)
        score += evaluateTigerTraps(for: game)
        score += evaluateTigerMobility(for: game)
        score += evaluateTigerCapturePotential(for: game)
        score += evaluateGoatSafetyAndTigerThreat(for: game)

        return score
    }

    private func evaluateEndgame(for game: BaghChalGame) -> Double {
        switch game.winner() {
        case "G": return Double.infinity // Goats win
        case "B": return -Double.infinity // Tigers win
        default: return 0
        }
    }

    private func evaluateGoatCaptures(for game: BaghChalGame) -> Double {
        let goatWeight = 10.0
        return goatWeight * Double(game.goatsCaptured)
    }

    private func evaluateTigerTraps(for game: BaghChalGame) -> Double {
        let tigerWeight = 15.0
        return tigerWeight * Double(game.baghsTrapped)
    }

    private func evaluateTigerMobility(for game: BaghChalGame) -> Double {
        let mobilityWeight = 5.0
        let tigerMobility = game.tigerPositions.map { position -> Int in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.count
        }.reduce(0, +)
        return mobilityWeight * Double(tigerMobility)
    }

    private func evaluateTigerCapturePotential(for game: BaghChalGame) -> Double {
        let captureWeight = 200.0
        let capturePotential = game.tigerPositions.contains { position -> Bool in
            var moves: [Move] = []
            game.addTigerMoves(from: game.convertToGridPoint(position), to: &moves)
            return moves.contains { move in game.canTigerCapture(from: game.convertToCGPoint(move.from), to: game.convertToCGPoint(move.to)) }
        }
        return capturePotential ? captureWeight : 0
    }

    private func evaluateGoatSafetyAndTigerThreat(for game: BaghChalGame) -> Double {
        let goatSafetyWeight = 5.0
        let tigerThreatWeight = 10.0
        var score = 0.0

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

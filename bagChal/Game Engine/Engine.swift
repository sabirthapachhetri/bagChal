//
//  Engine.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation

class Engine {
//    var depth: Int
//
//    init(depth: Int = 5) {
//        self.depth = depth
//    }
//
//    // A simple static evaluation function
//    func staticEvaluation(for game: BaghChalGame) -> Double {
//        // This is a basic heuristic. You may need to adjust it based on the game's rules and strategies.
//        let score = 10.0 * Double(game.goatsCaptured) - 5.0 * Double(game.baghsTrapped)
//        return score
//    }
//
//    // The minimax algorithm with alpha-beta pruning
//    func minimax(game: BaghChalGame, depth: Int, alpha: Double, beta: Double, maximizingPlayer: Bool) -> Double {
//        if depth == 0 || game.isGameOver {
//            return staticEvaluation(for: game)
//        }
//
//        var alpha = alpha
//        var beta = beta
//
//        if maximizingPlayer {
//            var maxEval = -Double.infinity
//            for move in game.possibleMoves() {
//                let evaluation = minimax(game: game.simulateMove(move), depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
//                maxEval = max(maxEval, evaluation)
//                alpha = max(alpha, evaluation)
//                if beta <= alpha {
//                    break
//                }
//            }
//            return maxEval
//        } else {
//            var minEval = Double.infinity
//            for move in game.possibleMoves() {
//                let evaluation = minimax(game: game.simulateMove(move), depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
//                minEval = min(minEval, evaluation)
//                beta = min(beta, evaluation)
//                if beta <= alpha {
//                    break
//                }
//            }
//            return minEval
//        }
//    }
//
//    // Determine the best move for the current player
//    func bestMove(for game: BaghChalGame) -> Move {
//        var bestScore = (game.nextTurn == "G" ? -Double.infinity : Double.infinity)
//        var bestMove: Move?
//
//        for move in game.possibleMoves() {
//            let score = minimax(game: game.simulateMove(move), depth: depth, alpha: -Double.infinity, beta: Double.infinity, maximizingPlayer: game.nextTurn == "G")
//            
//            if (game.nextTurn == "G" && score > bestScore) || (game.nextTurn == "B" && score < bestScore) {
//                bestScore = score
//                bestMove = move
//            }
//        }
//
//        return bestMove ?? Move.defaultMove() // Implement a default move if no other move is found
//    }
}

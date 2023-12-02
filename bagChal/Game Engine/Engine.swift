//
//  Engine.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation

let INF: Double = 1e6

class Engine {

    var depth: Int

    init(depth: Int = 5) {
        self.depth = depth
    }

    func staticEvaluation(for game: BaghChalGame) -> Double {
        if !game.isGameOver() {
            return 150.0 * Double(game.baghsTrapped) - 120.0 * Double(game.goatsCaptured)
        }
        guard let winner = game.winner() else { return 0.0 }
        if winner == "G" {
            return INF
        } else if winner == "B" {
            return -INF
        } else {
            return 0.0
        }
    }

    func minimax(game: BaghChalGame, depth: Int, alpha: Double, beta: Double, maxPlayer: Bool) -> (move: Move?, eval: Double) {
        if depth == 0 || game.isGameOver() {
            return (nil, staticEvaluation(for: game))
        }

        var localAlpha = alpha
        var localBeta = beta

        if maxPlayer {
            var maxEval = -INF
            var bestMove: Move? = nil
            for move in game.possibleMoves() {
                let gCopy = game.copy()
                gCopy.move(move)
                let eval = minimax(game: gCopy, depth: depth - 1, alpha: localAlpha, beta: localBeta, maxPlayer: false).eval
                if eval > maxEval {
                    maxEval = eval
                    bestMove = move
                }
                localAlpha = max(localAlpha, eval)
                if localBeta <= localAlpha {
                    break
                }
            }
            return (bestMove, maxEval)
        } else {
            var minEval = INF
            var bestMove: Move? = nil
            for move in game.possibleMoves() {
                let gCopy = game.copy()
                gCopy.move(move)
                let eval = minimax(game: gCopy, depth: depth - 1, alpha: localAlpha, beta: localBeta, maxPlayer: true).eval
                if eval < minEval {
                    minEval = eval
                    bestMove = move
                }
                localBeta = min(localBeta, eval)
                if localBeta <= localAlpha {
                    break
                }
            }
            return (bestMove, minEval)
        }
    }

    func bestBaghMove(for game: BaghChalGame) -> (move: Move?, eval: Double) {
        assert(!game.isGameOver())
        return minimax(game: game, depth: depth, alpha: -INF, beta: INF, maxPlayer: false)
    }

    func bestGoatMove(for game: BaghChalGame) -> (move: Move?, eval: Double) {
        assert(!game.isGameOver())
        return minimax(game: game, depth: depth, alpha: -INF, beta: INF, maxPlayer: true)
    }

    func getBestMove(for game: BaghChalGame) -> (move: Move?, eval: Double) {
        if game.nextTurn == "G" {
            return bestGoatMove(for: game)
        } else {
            return bestBaghMove(for: game)
        }
    }
}

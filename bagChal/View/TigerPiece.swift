//
//  TigerPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

struct TigerPiece: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    @ObservedObject var game: BaghChalGame

    var body: some View {
        ForEach(0..<tigerPositions.count, id: \.self) { index in
            Image("tiger")
                .resizable()
                .frame(width: diameter, height: diameter)
                .position(tigerPositions[index])
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if game.nextTurn == "B" {
                                let draggedPosition = CGPoint(
                                    x: tigerPositions[index].x + gesture.translation.width,
                                    y: tigerPositions[index].y + gesture.translation.height
                                )
                                let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

                                var moveMade = false // Flag to check if a move has been made

                                // First, check if the tiger can capture a goat
                                if game.canTigerCapture(from: tigerPositions[index], to: nearestIntersectionPoint) {
                                    // Perform the capture move
                                    game.performTigerCapture(from: tigerPositions[index], to: nearestIntersectionPoint)
                                    tigerPositions[index] = nearestIntersectionPoint
                                    moveMade = true
                                }
                                // If not a capture move, check if it's a valid regular move
                                else if game.isValidTigerMove(from: tigerPositions[index], to: nearestIntersectionPoint) {
                                    // Update tiger position for a regular move
                                    tigerPositions[index] = nearestIntersectionPoint
                                    moveMade = true
                                }

                                if moveMade {
                                    // Update the game state and switch turns only if a valid move was made
                                    game.updateGameState()
                                    game.nextTurn = "G"
                                } else {
                                    // Revert to original position if the move is not valid
                                    tigerPositions[index] = game.convertToCGPoint(game.convertToGridPoint(tigerPositions[index]))
                                }
                            }
                        }
                )
        }
    }
}


////
////  TigerPiece.swift
////  bagChal
////
////  Created by Sabir Thapa on 27/11/2023.
////
//
//import SwiftUI
//
//struct TigerPiece: View {
//    let rows: Int
//    let columns: Int
//    let spacing: CGFloat
//    let diameter: CGFloat
//
//    @Binding var goatPositions: [CGPoint]
//    @Binding var tigerPositions: [CGPoint]
//    @ObservedObject var game: BaghChalGame
//
//    var body: some View {
//        ForEach(0..<tigerPositions.count, id: \.self) { index in
//            Image("tiger")
//                .resizable()
//                .frame(width: diameter, height: diameter)
//                .position(tigerPositions[index])
//        }
//        .onChange(of: game.nextTurn) { newTurn in
//            if newTurn == "B" {
//                performAITigerMove()
//            }
//        }
//    }
//
//    private func performAITigerMove() {
//        // AI logic to determine the best move for tigers
//        if let bestMove = game.bestMoveForTigers() {
//            // Perform the move
//            game.applyMove(bestMove)
//
//            // Update tiger positions on the board
//            tigerPositions = game.tigerPositions
//
//            // Update game state and switch turns
//            game.updateGameState()
//            game.nextTurn = "G" // Change turn to goats
//        }
//    }
//}

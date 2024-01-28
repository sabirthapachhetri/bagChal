//
//  MPTigerPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import SwiftUI

struct MPTigerPiece: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
   
    var body: some View {
        ForEach(0..<tigerPositions.count, id: \.self) { index in
            Image("tiger")
                .resizable()
                .frame(width: diameter, height: diameter)
                .position(tigerPositions[index])
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            handleTigerDrag(index: index, gesture: gesture)
                        }
                )
        }
    }
    
    func handleTigerDrag(index: Int, gesture: DragGesture.Value) {
        if game.player2.isCurrent {
            let draggedPosition = CGPoint(
                x: tigerPositions[index].x + gesture.translation.width,
                y: tigerPositions[index].y + gesture.translation.height
            )
            let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

            // Calculate fromPoint before updating tigerPositions[index]
            let fromPoint = game.convertToGridPoint(tigerPositions[index])

            var moveMade = false

            if game.canTigerCapture(from: tigerPositions[index], to: nearestIntersectionPoint) {
                game.performTigerCapture(from: tigerPositions[index], to: nearestIntersectionPoint)
                tigerPositions[index] = nearestIntersectionPoint
                moveMade = true
            } else if game.isValidTigerMove(from: tigerPositions[index], to: nearestIntersectionPoint) {
                tigerPositions[index] = nearestIntersectionPoint
                moveMade = true
            }

            if moveMade {
                // Calculate toPoint after updating tigerPositions[index]
                let toPoint = game.convertToGridPoint(nearestIntersectionPoint)

                // Send move data if in peer-to-peer game mode
                if game.gameType == .peer {
                    let gameMove = MPGameMove(action: .move, playerName: connectionManager.myPeerId.displayName, move: Move(from: fromPoint, to: toPoint))
                    connectionManager.send(gameMove: gameMove)
                }
                game.updateGameState()
                game.toggleCurrentPlayer()
            } else {
                // Revert the position if the move wasn't made
                tigerPositions[index] = game.convertToCGPoint(fromPoint)
            }
        }
    }

}

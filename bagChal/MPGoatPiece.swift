//
//  MPGoatPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import SwiftUI

struct MPGoatPiece: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    var totalGoats = 20
    let basePosition = CGPoint(x: 160, y: 5 * 80)
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager

    var body: some View {
        ZStack {
            ForEach(0..<goatPositions.count, id: \.self) { index in
                Image("goat")
                    .resizable()
                    .frame(width: diameter, height: diameter)
                    .position(goatPositions[index])
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                handleGoatDrag(index: index, gesture: gesture)
                            }
                    )
            }
        }
    }

    private func handleGoatDrag(index: Int, gesture: DragGesture.Value) {
        if game.player1.isCurrent {
            let draggedPosition = CGPoint(
                x: goatPositions[index].x + gesture.translation.width,
                y: goatPositions[index].y + gesture.translation.height
            )
            let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

            let fromPoint = game.convertToGridPoint(goatPositions[index])

            if game.isValidGoatMove(from: goatPositions[index], to: nearestIntersectionPoint) {
                goatPositions[index] = nearestIntersectionPoint

                if !game.isPointWithinBoard(goatPositions[index]) {
                    game.goatsPlaced += 1
                }

                let toPoint = game.convertToGridPoint(nearestIntersectionPoint)

                if game.gameType == .peer {
                    let gameMove = MPGameMove(action: .move, playerName: connectionManager.myPeerId.displayName, move: Move(from: fromPoint, to: toPoint))
                    connectionManager.send(gameMove: gameMove)
                }
                game.updateGameState()
                game.toggleCurrentPlayer()
            } else {
                goatPositions[index] = game.convertToCGPoint(fromPoint)
            }
        }
    }
}


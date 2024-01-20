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
    var isAITiger: Bool 

    var body: some View {
        ForEach(0..<tigerPositions.count, id: \.self) { index in
            Image("tiger")
                .resizable()
                .frame(width: diameter, height: diameter)
                .position(tigerPositions[index])
                .gesture(
                    isAITiger ? nil : DragGesture()
                        .onEnded { gesture in
                            handleTigerDrag(index: index, gesture: gesture)
                        }
                )
        }
        .onChange(of: game.nextTurn) { newTurn in
            if newTurn == "B" && isAITiger {
                performAITigerMove()
            }
        }
    }

    private func handleTigerDrag(index: Int, gesture: DragGesture.Value) {
        if game.nextTurn == "B" {
            let draggedPosition = CGPoint(
                x: tigerPositions[index].x + gesture.translation.width,
                y: tigerPositions[index].y + gesture.translation.height
            )
            let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

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
                game.updateGameState()
                game.nextTurn = "G"
            } else {
                tigerPositions[index] = game.convertToCGPoint(game.convertToGridPoint(tigerPositions[index]))
            }
        }
    }

    private func performAITigerMove() {
         if let bestMove = game.bestMoveForTigers() {
             game.applyTigerMove(bestMove)
             tigerPositions = game.tigerPositions
             game.updateGameState()
             game.nextTurn = "G"
         }
    }
}

//
//  GoatPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

struct GoatPiece: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    var totalGoats = 20
    let basePosition = CGPoint(x: 160, y: 5 * 80)
    @ObservedObject var game: BaghChalGame
    var isAIGoat: Bool
    
    var body: some View {
        ZStack {
            Text("\(totalGoats - game.goatsPlaced)")
                .font(.title)
                .foregroundColor(.black)
                .position(x: basePosition.x, y: basePosition.y + diameter)
                .frame(alignment: .center)

            ForEach(0..<goatPositions.count, id: \.self) { index in
                Image("goat")
                    .resizable()
                    .frame(width: diameter, height: diameter)
                    .position(goatPositions[index])
                    .gesture(
                        isAIGoat ? nil : DragGesture()
                            .onEnded { gesture in
                                handleGoatDrag(index: index, gesture: gesture)
                            }
                    )
            }
        }
        .onChange(of: game.nextTurn) { newTurn in
            if newTurn == "G" && isAIGoat {
                performAIGoatMove()
            }
        }
    }

    private func handleGoatDrag(index: Int, gesture: DragGesture.Value) {
        if game.nextTurn == "G" {
            let draggedPosition = CGPoint(
                x: goatPositions[index].x + gesture.translation.width,
                y: goatPositions[index].y + gesture.translation.height
            )
            let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

            if game.isValidGoatMove(from: goatPositions[index], to: nearestIntersectionPoint) {
                goatPositions[index] = nearestIntersectionPoint
                game.nextTurn = "B"
                game.goatsPlaced += 1

            } else {
                goatPositions[index] = game.convertToCGPoint(game.convertToGridPoint(goatPositions[index]))
            }
            game.updateGameState()
        }
    }

    private func performAIGoatMove() {
         if let bestMove = game.bestMoveForGoats() {
             game.applyGoatMove(bestMove)
             goatPositions = game.goatPositions
             game.updateGameState()
             game.nextTurn = "B"
         }
    }
}

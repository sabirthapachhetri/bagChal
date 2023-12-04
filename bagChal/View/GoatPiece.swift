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
    @ObservedObject var game: BaghChalGame
    var totalGoats = 20
    let basePosition = CGPoint(x:160, y: 5 * 80)

    
    var body: some View {
        ZStack {
            // Counter for the goats in the holding area
            Text("\(totalGoats - game.goatsPlaced)")
                .font(.title) // Adjust font as needed
                .foregroundColor(.black) // Adjust color as needed
                .position(x: basePosition.x, y: basePosition.y + diameter) // Adjust positioning as needed
                .frame(alignment: .center)

            ForEach(0..<goatPositions.count, id: \.self) { index in
                Image("goat")
                    .resizable()
                    .frame(width: diameter, height: diameter)
                    .position(goatPositions[index])
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                if game.nextTurn == "G" {
                                    let draggedPosition = CGPoint(
                                        x: goatPositions[index].x + gesture.translation.width,
                                        y: goatPositions[index].y + gesture.translation.height
                                    )

                                    let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

                                    // Update the goat's position only if it's a valid move
                                    if game.isValidGoatMove(from: goatPositions[index], to: nearestIntersectionPoint) {
                                        let isGoatInHoldingArea = !game.isPointWithinBoard(goatPositions[index])
                                        if isGoatInHoldingArea {
                                            game.goatsPlaced += 1
                                            print("No of goats Placed: \(game.goatsPlaced)")
                                            goatPositions[index] = nearestIntersectionPoint
                                        }
                                    } else {
                                        goatPositions[index] = game.convertToCGPoint(game.convertToGridPoint(goatPositions[index]))
                                    }

                                    game.nextTurn = "B"
                                }
                            }
                    )
            }
        }
    }
}

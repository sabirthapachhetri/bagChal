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
                        .onChanged { gesture in
                            print("Dragging to: \(gesture.location)")
                        }
                        .onEnded { gesture in

                            if game.nextTurn == "B" {
                                let draggedPosition = CGPoint(
                                    x: tigerPositions[index].x + gesture.translation.width,
                                    y: tigerPositions[index].y + gesture.translation.height
                                )
                                let nearestIntersectionPoint = game.convertToCGPoint(game.convertToGridPoint(draggedPosition))

                                if game.isValidTigerMove(from: tigerPositions[index], to: nearestIntersectionPoint) {
                                    self.tigerPositions[index] = nearestIntersectionPoint
                                } else {
                                    tigerPositions[index] = game.convertToCGPoint(game.convertToGridPoint(tigerPositions[index]))
                                }

                                if game.isTigerTrapped(at: tigerPositions[index]) {

                                    print("Tiger at index \(index) is trapped.")
                                    game.tigerTrapped()
                                }

                                game.nextTurn = "G"
                            }
                        }
                )
        }
    }
}

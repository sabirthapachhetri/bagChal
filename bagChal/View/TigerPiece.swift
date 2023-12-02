//
//  TigerPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

struct TigerPiece: View {
    @Binding var tigerPositions: [CGPoint]
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    // Function to check if a position is adjacent to a tiger's position
    private func isAdjacentPosition(for tigerIndex: Int, position: CGPoint) -> Bool {
        let currentPos = tigerPositions[tigerIndex]
        let dx = abs(position.x - currentPos.x)
        let dy = abs(position.y - currentPos.y)

        // Check for one spacing away horizontally or vertically
        let isAdjacentHorizontally = dx == spacing && dy == 0
        let isAdjacentVertically = dy == spacing && dx == 0
        // Check for diagonal movement
        let isAdjacentDiagonally = dx == spacing && dy == spacing

        return isAdjacentHorizontally || isAdjacentVertically || isAdjacentDiagonally
    }
    
    // Function to calculate the nearest intersection point
    private func nearestIntersection(to point: CGPoint) -> CGPoint {
        let x = round(point.x / spacing) * spacing
        let y = round(point.y / spacing) * spacing
        // Make sure the values are clamped within the game board bounds
        return CGPoint(x: max(min(x, spacing * CGFloat(columns - 1)), 0),
                       y: max(min(y, spacing * CGFloat(rows - 1)), 0))
    }

    var body: some View {
        // Draw the tiger images with draggable functionality
        ForEach(0..<tigerPositions.count, id: \.self) { index in
            Image("tiger") // Ensure you have an image named "tiger" in your assets
                .resizable()
                .frame(width: diameter, height: diameter)
                .position(tigerPositions[index])
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            // Calculate the dragged position
                            let draggedPosition = CGPoint(
                                x: tigerPositions[index].x + gesture.translation.width,
                                y: tigerPositions[index].y + gesture.translation.height
                            )

                            // Calculate the nearest intersection from the dragged position
                            let nearestIntersectionPoint = self.nearestIntersection(to: draggedPosition)

                            // Check if the nearest intersection is adjacent (including diagonally)
                            if self.isAdjacentPosition(for: index, position: nearestIntersectionPoint) {
                                // Check if the nearest intersection is within the grid bounds
                                if (0...self.spacing * CGFloat(self.columns - 1)).contains(nearestIntersectionPoint.x) &&
                                   (0...self.spacing * CGFloat(self.rows - 1)).contains(nearestIntersectionPoint.y) {
                                    self.tigerPositions[index] = nearestIntersectionPoint // Update if valid move
                                } else {
                                    // Reset to original position if out of bounds
                                    self.tigerPositions[index] = self.nearestIntersection(to: self.tigerPositions[index])
                                }
                            } else {
                                // Reset to original position if not a valid move
                                self.tigerPositions[index] = self.nearestIntersection(to: self.tigerPositions[index])
                            }
                        }
                )
        }
    }
}

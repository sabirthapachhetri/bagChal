//
//  GoatPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

struct GoatPiece: View {
    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint] // Needed to check for occupied intersections
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    // Function to calculate the nearest intersection point
    private func nearestIntersection(to point: CGPoint) -> CGPoint {
        let x = round(point.x / spacing) * spacing
        let y = round(point.y / spacing) * spacing
        return CGPoint(x: max(min(x, spacing * CGFloat(columns - 1)), 0),
                       y: max(min(y, spacing * CGFloat(rows - 1)), 0))
    }

    // Function to check if an intersection is free (not occupied by goats or tigers)
    private func isIntersectionFree(_ point: CGPoint) -> Bool {
        !goatPositions.contains(point) && !tigerPositions.contains(point)
    }
    
    // Function to check if a point is within board boundaries
    private func isPointWithinBoard(_ point: CGPoint) -> Bool {
        (0 <= point.x && point.x <= spacing * CGFloat(columns - 1)) &&
        (0 <= point.y && point.y <= spacing * CGFloat(rows - 1))
    }

    var body: some View {
        // Draw the goat images with draggable functionality
        ForEach(0..<goatPositions.count, id: \.self) { index in
            Image("goat") // Ensure you have an image named "goat" in your assets
                .resizable()
                .frame(width: diameter, height: diameter)
                .position(goatPositions[index])
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            let draggedPosition = CGPoint(
                                x: goatPositions[index].x + gesture.translation.width,
                                y: goatPositions[index].y + gesture.translation.height
                            )
                            
                            let nearestIntersectionPoint = self.nearestIntersection(to: draggedPosition)
                            
                            // Check if the nearest intersection is free and within board boundaries
                            if self.isIntersectionFree(nearestIntersectionPoint) && self.isPointWithinBoard(nearestIntersectionPoint) {
                                goatPositions[index] = nearestIntersectionPoint // Update if valid move
                            } else {
                                // If the goat is not yet on the board, allow it to stay in the holding area
                                // Otherwise, reset to the nearest intersection within the board
                                let isGoatInHoldingArea = !self.isPointWithinBoard(goatPositions[index])
                                goatPositions[index] = isGoatInHoldingArea ? goatPositions[index] : self.nearestIntersection(to: goatPositions[index])
                            }
                        }
                )
        }
    }
}

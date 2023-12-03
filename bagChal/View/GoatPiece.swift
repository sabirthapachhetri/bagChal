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
    var connectedPointsDict: [Point: Set<Point>] // Dictionary of connected points
    
    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    @Binding var game: BaghChalGame // Add this line

    @State private var goatsPlaced = 0

    // Convert CGPoint to Point struct
    private func convertToGridPoint(_ point: CGPoint) -> Point {
        let x = Int(round(point.x / spacing)) + 1 // Adjust for 1-indexing
        let y = Int(round(point.y / spacing)) + 1 // Adjust for 1-indexing
        return Point(x: x, y: y)
    }

    // Convert Point struct to CGPoint
    private func convertToCGPoint(_ point: Point) -> CGPoint {
        let x = CGFloat(point.x - 1) * spacing // Adjust for 1-indexing
        let y = CGFloat(point.y - 1) * spacing // Adjust for 1-indexing
        return CGPoint(x: x, y: y)
    }

    // Function to check if an intersection is free (not occupied by goats or tigers)
    private func isIntersectionFree(_ point: CGPoint) -> Bool {
        !goatPositions.contains(point) && !tigerPositions.contains(point)
    }

    private func isValidGoatMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        // Check if all goats are placed
        if goatsPlaced >= 20 {
            // Movement logic for after all goats are placed
            let currentGridPoint = convertToGridPoint(currentPos)
            let newGridPoint = convertToGridPoint(newPos)

            guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return false }

            let isAdjacent = connectedPoints.contains(newGridPoint)
            let isFree = isIntersectionFree(newPos)

            return isAdjacent && isFree
        } else {
            // If the goat is already on the board, it cannot move until all goats are placed
            if isPointWithinBoard(currentPos) {
                return false
            }
            // If the goat is not on the board, check if the new position is free
            return isIntersectionFree(newPos)
        }
    }

    // Function to check if a point is within board boundaries
    private func isPointWithinBoard(_ point: CGPoint) -> Bool {
        (0 <= point.x && point.x <= spacing * CGFloat(columns - 1)) &&
        (0 <= point.y && point.y <= spacing * CGFloat(rows - 1))
    }

    var body: some View {
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

                                let nearestIntersectionPoint = self.convertToCGPoint(self.convertToGridPoint(draggedPosition))

                                // Update the goat's position only if it's a valid move
                                if self.isValidGoatMove(from: goatPositions[index], to: nearestIntersectionPoint) {
                                    goatsPlaced += 1
                                    print("No of goats Placed: \(goatsPlaced)")
                                    goatPositions[index] = nearestIntersectionPoint
                                    // Increment the count of goats placed if it's a new placement
                                    if !isPointWithinBoard(goatPositions[index]) {
                                        goatsPlaced += 1
                                    }
                                } else {
                                    let isGoatInHoldingArea = !self.isPointWithinBoard(goatPositions[index])
                                    goatPositions[index] = isGoatInHoldingArea ? goatPositions[index] : self.convertToCGPoint(self.convertToGridPoint(goatPositions[index]))
                                }
                                
                                game.nextTurn = "B"
                            }
                        }
                )
        }
    }
}

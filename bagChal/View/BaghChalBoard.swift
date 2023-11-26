//
//  BagChalBoard.swift
//  bagChal
//
//  Created by Sabir Thapa on 26/11/2023.
//

import SwiftUI

struct BaghChalBoard: View {
    // Constants for the layout and size of the board
    let columns = 5
    let rows = 5
    let spacing: CGFloat = 80 // Space between lines
    let lineWidth: CGFloat = 2 // Line thickness
    let intersectionCircleDiameter: CGFloat = 40 // Diameter for the intersection circles
    
    // State variables for draggable pieces
    @State private var goatPositions: [CGPoint]
    @State private var tigerPositions: [CGPoint]

    init() {
        _goatPositions = State(initialValue: Array(repeating: .zero, count: 20))
        // Initialize tigerPositions with the CGPoint values of the marked intersections
        _tigerPositions = State(initialValue: [
            CGPoint(x: 0 * spacing, y: 0 * spacing),       // Top-left
            CGPoint(x: 4 * spacing, y: 0 * spacing),       // Top-right
            CGPoint(x: 4 * spacing, y: 4 * spacing),       // Bottom-right
            CGPoint(x: 0 * spacing, y: 4 * spacing)        // Bottom-left
        ])
    }
    
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
        VStack {
            ZStack {
                // Draw the lines of the grid
                ForEach(0..<rows) { row in
                    Path { path in
                        let y = CGFloat(row) * spacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: spacing * CGFloat(columns - 1), y: y))
                    }
                    .stroke(Color.black, lineWidth: lineWidth)

                    Path { path in
                        let x = CGFloat(row) * spacing
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: spacing * CGFloat(columns - 1)))
                    }
                    .stroke(Color.black, lineWidth: lineWidth)
                }

                // Draw the existing diagonal lines
                Path { path in
                    // Top-left to bottom-right
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: spacing * CGFloat(columns - 1), y: spacing * CGFloat(rows - 1)))
                    // Top-right to bottom-left
                    path.move(to: CGPoint(x: spacing * CGFloat(columns - 1), y: 0))
                    path.addLine(to: CGPoint(x: 0, y: spacing * CGFloat(rows - 1)))
                }
                .stroke(Color.black, lineWidth: lineWidth)

                // Draw the new diagonal lines that connect the midpoints of the grid's sides
                Path { path in
                    // Calculate midpoints
                    let midX = spacing * 2
                    let midY = spacing * 2
                    // Top to bottom-right
                    path.move(to: CGPoint(x: midX, y: 0))
                    path.addLine(to: CGPoint(x: spacing * CGFloat(columns - 1), y: midY))
                    // Top-right to bottom
                    path.move(to: CGPoint(x: spacing * CGFloat(columns - 1), y: midY))
                    path.addLine(to: CGPoint(x: midX, y: spacing * CGFloat(rows - 1)))
                    // Bottom to top-left
                    path.move(to: CGPoint(x: midX, y: spacing * CGFloat(rows - 1)))
                    path.addLine(to: CGPoint(x: 0, y: midY))
                    // Top-left to bottom
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: midX, y: 0))
                }
                .stroke(Color.black, lineWidth: lineWidth)

                // Draw the intersection circles
                ForEach(0..<rows) { row in
                    ForEach(0..<columns) { column in
                        Circle()
                            .fill(Color.white)
                            .frame(width: intersectionCircleDiameter, height: intersectionCircleDiameter)
                            .position(x: CGFloat(column) * spacing, y: CGFloat(row) * spacing)
                    }
                }
                
                // Draw the tiger images with draggable functionality
                ForEach(0..<tigerPositions.count, id: \.self) { index in
                    Image("tiger")
                        .resizable()
                        .frame(width: intersectionCircleDiameter, height: intersectionCircleDiameter)
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
            .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
            .padding(spacing)
            
            // Goat images arranged in rows
            VStack(spacing: 10) { // This spacing is between each row of goats
                ForEach(0..<4, id: \.self) { rowIndex in // Creates 4 rows
                    HStack(spacing: 30) { // This spacing is between each goat in a row
                        ForEach(0..<5, id: \.self) { index in // Creates up to 5 goats per row
                            let goatIndex = rowIndex * 5 + index
                            if goatIndex < goatPositions.count { // Check if the goat index is within range
                                Image("goat")
                                    .resizable()
                                    .frame(width: intersectionCircleDiameter, height: intersectionCircleDiameter)
                                    .offset(x: goatPositions[goatIndex].x, y: goatPositions[goatIndex].y)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                goatPositions[goatIndex].x = gesture.translation.width + goatPositions[goatIndex].x
                                                goatPositions[goatIndex].y = gesture.translation.height + goatPositions[goatIndex].y
                                            }
                                            .onEnded { gesture in
                                                // Handle snapping to grid or resetting position here
                                                goatPositions[goatIndex].x = 0
                                                goatPositions[goatIndex].y = 600 // Replace with logic to snap to the grid
                                            }
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}

struct BagChalBoard_Previews: PreviewProvider {
    static var previews: some View {
        BaghChalBoard()
    }
}

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

    var body: some View {
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
            .stroke(Color.black, lineWidth: lineWidth) // Use red color to match the marked lines

            // Draw the intersection circles
            ForEach(0..<rows) { row in
                ForEach(0..<columns) { column in
                    Circle()
                        .fill(Color.white)
                        .frame(width: intersectionCircleDiameter, height: intersectionCircleDiameter)
                        .position(x: CGFloat(column) * spacing, y: CGFloat(row) * spacing)
                }
            }
        }
        .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
        .padding(spacing)
    }
}



struct BagChalBoard_Previews: PreviewProvider {
    static var previews: some View {
        BaghChalBoard()
    }
}
//
//  TigerPiece.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

import SwiftUI

struct TigerPiece: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat
    var connectedPointsDict: [Point: Set<Point>]
    
    @Binding var goatPositions: [CGPoint]
    @Binding var tigerPositions: [CGPoint]
    @Binding var game: BaghChalGame


    private func convertToGridPoint(_ point: CGPoint) -> Point {
        let x = Int(round(point.x / spacing)) + 1  // Adjust for 1-indexing
        let y = Int(round(point.y / spacing)) + 1  // Adjust for 1-indexing
        return Point(x: x, y: y)
    }

    private func convertToCGPoint(_ point: Point) -> CGPoint {
        let x = CGFloat(point.x - 1) * spacing  // Adjust for 1-indexing
        let y = CGFloat(point.y - 1) * spacing  // Adjust for 1-indexing
        return CGPoint(x: x, y: y)
    }

    // Check if the new position is adjacent and valid according to the game rules
    private func isValidTigerMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)
            
        guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return false }
        
        let isAdjacent = connectedPoints.contains(newGridPoint)
        let isFree = !goatPositions.contains(newPos) && !tigerPositions.contains(newPos)
                
        return isAdjacent && isFree
    }

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
                                print("Drag ended at: \(draggedPosition)")
                                let nearestIntersectionPoint = self.convertToCGPoint(self.convertToGridPoint(draggedPosition))
                                print("Nearest intersection: \(nearestIntersectionPoint)")
                                
                                if self.isValidTigerMove(from: tigerPositions[index], to: nearestIntersectionPoint) {
                                    self.tigerPositions[index] = nearestIntersectionPoint
                                    print("Move is valid")
                                } else {
                                    print("Move is not valid")
                                    tigerPositions[index] = self.convertToCGPoint(self.convertToGridPoint(tigerPositions[index]))
                                }
                                
                                game.nextTurn = "G"
                            }
                        }
                )

        }
    }
}

//  BaghChalGame.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation
import Combine

class BaghChalGame: ObservableObject {
    // Game state properties
    @Published var baghsTrapped: Int = 0
    @Published var goatsCaptured: Int = 0
    @Published var nextTurn: String = "G" // or "B"
    @Published var goatsPlaced: Int = 0 // Number of goats placed on the board
    @Published var tigerPositions: [CGPoint]
    @Published var goatPositions: [CGPoint]

    var connectedPointsDict: [Point: Set<Point>]

    let rows: Int // Set as needed
    let columns: Int // Set as needed
    let spacing: CGFloat // Set as needed
    let diameter: CGFloat // Set as needed

    init(spacing: CGFloat, rows: Int, columns: Int, diameter: CGFloat, connectedPointsDict: [Point: Set<Point>]) {
        
        self.spacing = spacing
        self.rows = rows
        self.columns = columns
        self.diameter = diameter
        self.connectedPointsDict = connectedPointsDict

        // Initialize tiger positions
        self.tigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),       // Top-left
            CGPoint(x: 4 * spacing, y: 0 * spacing),       //  Top-right
            CGPoint(x: 4 * spacing, y: 4 * spacing),       // Bottom-right
            CGPoint(x: 0 * spacing, y: 4 * spacing)        // Bottom-left
        ]

        // Initialize goat positions in an overlay style
        let basePosition = CGPoint(x:160, y: 5 * spacing) // Base position for the first goat
        let overlayOffset = CGPoint(x: 0, y: 0) // Define the offset for overlaying goats

        self.goatPositions = (0..<20).map { index in
            // Calculate the offset for each goat based on its index
            let xOffset = CGFloat(index) * overlayOffset.x
            let yOffset = CGFloat(index) * overlayOffset.y

            // Apply the offset to the base position
            return CGPoint(x: basePosition.x + xOffset, y: basePosition.y + yOffset)
        }
    }

    func convertToGridPoint(_ point: CGPoint) -> Point {
        let x = Int(round(point.x / spacing)) + 1  // Adjust for 1-indexing
        let y = Int(round(point.y / spacing)) + 1  // Adjust for 1-indexing
        return Point(x: x, y: y)
    }

    func convertToCGPoint(_ point: Point) -> CGPoint {
        let x = CGFloat(point.x - 1) * spacing  // Adjust for 1-indexing
        let y = CGFloat(point.y - 1) * spacing  // Adjust for 1-indexing
        return CGPoint(x: x, y: y)
    }
    
    // Function to check if a point is within board boundaries
    func isPointWithinBoard(_ point: CGPoint) -> Bool {
        (0 <= point.x && point.x <= spacing * CGFloat(columns - 1)) &&
        (0 <= point.y && point.y <= spacing * CGFloat(rows - 1))
    }
    
    // Function to check if an intersection is free (not occupied by goats or tigers)
    func isIntersectionFree(_ point: CGPoint) -> Bool {
        !goatPositions.contains(point) && !tigerPositions.contains(point)
    }

    // Check if the new position is adjacent and valid according to the game rules
    func isValidTigerMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)

        guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return false }

        let isAdjacent = connectedPoints.contains(newGridPoint)
        
        let isFree = isIntersectionFree(newPos)

        updateGameState()
        return isAdjacent && isFree
    }

    // Add a method to check if the tiger is trapped
    func isTigerTrapped(at position: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(position)
        guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return true }

        // Check if all adjacent points are occupied by tigers or goats
        for point in connectedPoints {
            let adjacentPosition = convertToCGPoint(point)
            if !goatPositions.contains(adjacentPosition) && !tigerPositions.contains(adjacentPosition) {
                return false
            }
        }
        return true
    }

    // Call this method after each move to check if any tiger is trapped
    func checkTigersTrapped(tigerPositions: [CGPoint]) {
        for position in tigerPositions {
            if isTigerTrapped(at: position) {
                self.baghsTrapped += 1
            }
        }
    }

    func tigerTrapped() {
        self.baghsTrapped += 1
    }

    func updateGameState() {
        checkTigersTrapped(tigerPositions: self.tigerPositions)
    }
 
    func isValidGoatMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
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
}


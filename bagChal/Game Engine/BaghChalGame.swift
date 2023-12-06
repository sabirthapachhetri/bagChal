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
    @Published var isGameOver: Bool = false
    @Published var winningSide: String = ""
    
    var connectedPointsDict: [Point: Set<Point>]
    var trappedTigers: Set<Int> = [] // Tracks indices of trapped tigers

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

    func isValidTigerMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)

        guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return false }

        let isAdjacent = connectedPoints.contains(newGridPoint)
        let isFree = isIntersectionFree(newPos)

        return isAdjacent && isFree
    }

    func updateTrappedTigers() {
        for (index, position) in tigerPositions.enumerated() {
            if isTigerTrapped(at: position) {
                trappedTigers.insert(index)
            } else {
                trappedTigers.remove(index)
            }
        }
        baghsTrapped = trappedTigers.count
        
        // Check if all tigers are trapped and update game over state
        if baghsTrapped == 4 {
            isGameOver = true
            winningSide = "Goats"
        }
    }
    
    func isTigerTrapped(at position: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(position)
        guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return true }

        for point in connectedPoints {
            let adjacentPosition = convertToCGPoint(point)
            if isIntersectionFree(adjacentPosition) {
                return false
            }
        }
        return true
    }

    func updateGameState() {
        updateTrappedTigers()
    }
 
    func isValidGoatMove(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        // Movement is only valid within the board boundaries.
        guard isPointWithinBoard(newPos) else { return false }

        // If all goats are placed, they can only move to adjacent positions
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

extension BaghChalGame {
    func resetGame() {
        // Reset game state properties
        baghsTrapped = 0
        goatsCaptured = 0
        nextTurn = "G"
        goatsPlaced = 0
        isGameOver = false
        winningSide = ""

        // Reset tiger positions to initial locations
        tigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),       // Top-left
            CGPoint(x: 4 * spacing, y: 0 * spacing),       // Top-right
            CGPoint(x: 4 * spacing, y: 4 * spacing),       // Bottom-right
            CGPoint(x: 0 * spacing, y: 4 * spacing)        // Bottom-left
        ]

        // Reset goat positions to a holding area
        let basePosition = CGPoint(x: 160, y: 5 * spacing) // Adjust as needed for your holding area
        let overlayOffset = CGPoint(x: 0, y: 0) // Define the offset for overlaying goats in the holding area

        goatPositions = (0..<20).map { index in
            // Calculate the offset for each goat based on its index
            let xOffset = CGFloat(index) * overlayOffset.x
            let yOffset = CGFloat(index) * overlayOffset.y

            // Apply the offset to the base position
            return CGPoint(x: basePosition.x + xOffset, y: basePosition.y + yOffset)
        }

        // Reset the trappedTigers set
        trappedTigers.removeAll()
    }
}

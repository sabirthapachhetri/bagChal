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
    
    var engine: Engine

    init(spacing: CGFloat, rows: Int, columns: Int, diameter: CGFloat, connectedPointsDict: [Point: Set<Point>], engine: Engine = Engine()) {

        self.spacing = spacing
        self.rows = rows
        self.columns = columns
        self.diameter = diameter
        self.connectedPointsDict = connectedPointsDict
        self.engine = engine

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
    
    func canTigerCapture(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        // Convert CGPoints to grid Points
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)

        // Calculate the mid-grid point
        let midGridPoint = Point(x: (currentGridPoint.x + newGridPoint.x) / 2, y: (currentGridPoint.y + newGridPoint.y) / 2)

        // Convert the mid-grid point back to CGPoint to check the goat's position
        let midPoint = convertToCGPoint(midGridPoint)

        // Check if there's a goat at the mid-point and if the new position is free
        return goatPositions.contains(midPoint) && isIntersectionFree(newPos) &&
               baghSpecialCaptureMovesDict[currentGridPoint]?.contains(newGridPoint) == true
    }

    func performTigerCapture(from currentPos: CGPoint, to newPos: CGPoint) {
        // Convert CGPoints to grid Points for calculations
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)
        let midGridPoint = Point(x: (currentGridPoint.x + newGridPoint.x) / 2, y: (currentGridPoint.y + newGridPoint.y) / 2)

        // Convert the mid-grid point back to CGPoint for position manipulation
        let midPoint = convertToCGPoint(midGridPoint)

        // Remove the goat at the mid-point
        if let index = goatPositions.firstIndex(of: midPoint) {
            goatPositions.remove(at: index)
            goatsCaptured += 1
        }

        // Move the tiger to the new position
        if let tigerIndex = tigerPositions.firstIndex(of: currentPos) {
            tigerPositions[tigerIndex] = newPos
        }

        // Update game state after capture
        updateGameState()
    }
    
    func winner() -> String {
        if baghsTrapped == 4 { // Assuming there are 4 tigers and all being trapped means goats win
            return "G" // Goats win
        } else if goatsCaptured >= 5 { // Assuming capturing 5 goats means tigers win
            return "B" // Tigers win
        } else {
            return "" // No winner yet
        }
    }
    
    func simulateMove(_ move: Move) -> BaghChalGame {
        let simulatedGame = BaghChalGame(spacing: spacing, rows: rows, columns: columns, diameter: diameter, connectedPointsDict: connectedPointsDict)

        // Copy current game state
        simulatedGame.tigerPositions = self.tigerPositions
        simulatedGame.goatPositions = self.goatPositions
        simulatedGame.goatsPlaced = self.goatsPlaced
        simulatedGame.nextTurn = self.nextTurn
        simulatedGame.trappedTigers = self.trappedTigers

        // Apply the move
        let currentPosition = simulatedGame.convertToCGPoint(move.from)
        let newPosition = simulatedGame.convertToCGPoint(move.to)
        
        if nextTurn == "G" {
            // Handling goat move
            if simulatedGame.goatsPlaced < 20 {
                // Placing a new goat
                simulatedGame.goatPositions.append(newPosition)
                simulatedGame.goatsPlaced += 1
            } else {
                // Moving an existing goat
                if let index = simulatedGame.goatPositions.firstIndex(of: currentPosition) {
                    simulatedGame.goatPositions[index] = newPosition
                }
            }
        } else if nextTurn == "B" {
            // Handling tiger move
            if let index = simulatedGame.tigerPositions.firstIndex(of: currentPosition) {
                simulatedGame.tigerPositions[index] = newPosition
                // Check for capture
                if simulatedGame.canTigerCapture(from: currentPosition, to: newPosition) {
                    simulatedGame.performTigerCapture(from: currentPosition, to: newPosition)
                }
            }
        }

        // Update the game state after applying the move
        simulatedGame.updateGameState()
        return simulatedGame
    }
    
    func possibleMoves() -> [Move] {
        var moves: [Move] = []

        if nextTurn == "G" {
            // Goat's turn
            if goatsPlaced < 20 {
                // Placing goats
                for x in 1...rows {
                    for y in 1...columns {
                        let point = Point(x: x, y: y)
                        if isIntersectionFree(convertToCGPoint(point)) {
                            moves.append(Move(from: point, to: point)) // Placing goats
                        }
                    }
                }
            } else {
                // Moving goats
                for position in goatPositions {
                    let gridPoint = convertToGridPoint(position)
                    addGoatMoves(from: gridPoint, to: &moves)
                }
            }
        } else if nextTurn == "B" {
            // Tiger's turn
            for position in tigerPositions {
                let gridPoint = convertToGridPoint(position)
                addTigerMoves(from: gridPoint, to: &moves)
            }
        }

        return moves
    }

    // Helper function to add moves for goats
    func addGoatMoves(from gridPoint: Point, to moves: inout [Move]) {
        if let connectedPoints = connectedPointsDict[gridPoint] {
            for point in connectedPoints {
                if isIntersectionFree(convertToCGPoint(point)) {
                    moves.append(Move(from: gridPoint, to: point))
                }
            }
        }
    }

    // Helper function to add moves for tigers
    func addTigerMoves(from gridPoint: Point, to moves: inout [Move]) {
        if let connectedPoints = connectedPointsDict[gridPoint] {
            for point in connectedPoints {
                let newPos = convertToCGPoint(point)
                // Regular moves for tigers
                if isIntersectionFree(newPos) {
                    moves.append(Move(from: gridPoint, to: point))
                }
                // Capture moves for tigers
                if canTigerCapture(from: convertToCGPoint(gridPoint), to: newPos) {
                    moves.append(Move(from: gridPoint, to: point))
                }
            }
        }
    }
    
//    func bestMoveForTigers() -> Move? {
//        // Ensure it's the tiger's turn before proceeding
//        guard nextTurn == "B" else { return nil }
//
//        // Use the Engine to determine the best move
//        return engine.bestMove(for: self)
//    }
    
    func applyMove(_ move: Move) {
 
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)
        
        if nextTurn == "B" {
            // Applying tiger move
            if let index = self.tigerPositions.firstIndex(of: currentPosition) {
                self.tigerPositions[index] = newPosition
                if self.canTigerCapture(from: currentPosition, to: newPosition) {
                    self.performTigerCapture(from: currentPosition, to: newPosition)
                }
            }
        }

        // Update the game state after applying the move
        self.updateGameState()
        self.nextTurn = "G" // Switch to goat's turn
    }
    
    func applyGoatMove(_ move: Move) {
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)

        if nextTurn == "G" {
            // Applying goat move
            if goatsPlaced < 20 {
                // Placing a new goat
                if isIntersectionFree(newPosition) {
                    self.goatPositions.append(newPosition)
                    self.goatsPlaced += 1
                }
            } else {
                // Moving an existing goat
                if let index = self.goatPositions.firstIndex(of: currentPosition) {
                    if isValidGoatMove(from: currentPosition, to: newPosition) {
                        self.goatPositions[index] = newPosition
                    }
                }
            }
        }

        // Update the game state after applying the move
        self.updateGameState()
        self.nextTurn = "B" // Switch to tiger's turn
    }
    
    func bestMoveForTigers() -> Move? {
        // Ensure it's the tiger's turn before proceeding
        guard nextTurn == "B" else { return nil }

        var bestScore = -Double.infinity
        var bestMove: Move?

        for move in possibleMoves() {
            let score = evaluateMoveForTigers(move)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }

    private func evaluateMoveForTigers(_ move: Move) -> Double {
        // Implement your heuristic here. This could include factors like:
        // - Capturing goats
        // - Improving the positioning of tigers
        // - Avoiding traps or blockages
        // For now, let's return a random score as a placeholder.
        let simulatedGame = simulateMove(move)
         return engine.minimax(game: simulatedGame, depth: engine.depth, alpha: -engine.INF, beta: engine.INF, maximizingPlayer: true)
//        return Double.random(in: 0..<100)
    }
    
    func bestMoveForGoats() -> Move? {
        // Ensure it's the goat's turn before proceeding
        guard nextTurn == "G" else { return nil }

        var bestScore = -Double.infinity
        var bestMove: Move?

        for move in possibleMoves() {
            let score = evaluateMoveForGoats(move)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }

    private func evaluateMoveForGoats(_ move: Move) -> Double {
        // Implement your heuristic here. This could include factors like:
        // - Improving the position of goats
        // - Blocking tigers
        // - Ensuring goats are not easily captured
        // For now, let's return a random score as a placeholder.
//        return Double.random(in: 0..<100)
        let simulatedGame = simulateMove(move)
         return engine.minimax(game: simulatedGame, depth: engine.depth, alpha: -engine.INF, beta: engine.INF, maximizingPlayer: true)
    }
    
    // In BaghChalGame.swift
    func placeGoatAtNextAvailablePosition() {
        for x in 1...rows {
            for y in 1...columns {
                let gridPoint = Point(x: x, y: y)
                let potentialPosition = convertToCGPoint(gridPoint)
                if isIntersectionFree(potentialPosition) {
                    goatPositions.append(potentialPosition)
                    goatsPlaced += 1
                    updateGameState()
                    nextTurn = "B" // Change turn to tigers
                    return
                }
            }
        }
    }
}

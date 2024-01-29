//  BaghChalGame.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation
import SwiftUI
import Combine

class BaghChalGame: ObservableObject {
    @Published var baghsTrapped: Int = 0
    @Published var goatsCaptured: Int = 0
    @Published var nextTurn: String = "B" // or "B"
    @Published var goatsPlaced: Int = 0
    @Published var tigerPositions: [CGPoint]
    @Published var goatPositions: [CGPoint]
    @Published var winningSide: String = ""
    
    var connectedPointsDict: [Point: Set<Point>]
    var baghSpecialCaptureMovesDict: [Point: Set<Point>]
    var trappedTigers: Set<Int> = []

    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat
    
    var engine: Engine
    @Published var isGameOver: Bool = false
    
    func resetGame() {
        baghsTrapped = 0
        goatsCaptured = 0
        nextTurn = "G"
        goatsPlaced = 0
        isGameOver = false
        winningSide = ""

        tigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),
            CGPoint(x: 4 * spacing, y: 0 * spacing),
            CGPoint(x: 4 * spacing, y: 4 * spacing),
            CGPoint(x: 0 * spacing, y: 4 * spacing)
        ]

        let basePosition = CGPoint(x: 160, y: 5 * spacing)
        let overlayOffset = CGPoint(x: 0, y: 0)

        goatPositions = (0..<20).map { index in
            let xOffset = CGFloat(index) * overlayOffset.x
            let yOffset = CGFloat(index) * overlayOffset.y

            return CGPoint(x: basePosition.x + xOffset, y: basePosition.y + yOffset)
        }

        trappedTigers.removeAll()
    }
     
    func checkIfWinner() {
        let result = winner()

        if result == "G" {
            isGameOver = true
            winningSide = "Goats"
        } else if result == "B" {
            isGameOver = true
            winningSide = "Tigers"
        }
    }

    init(spacing: CGFloat, rows: Int, columns: Int, diameter: CGFloat, connectedPointsDict: [Point: Set<Point>], baghSpecialCaptureMovesDict: [Point: Set<Point>], engine: Engine = Engine()) {

        self.spacing = spacing
        self.rows = rows
        self.columns = columns
        self.diameter = diameter
        self.connectedPointsDict = connectedPointsDict
        self.baghSpecialCaptureMovesDict = baghSpecialCaptureMovesDict
        self.engine = engine

        self.tigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),
            CGPoint(x: 4 * spacing, y: 0 * spacing),
            CGPoint(x: 4 * spacing, y: 4 * spacing),
            CGPoint(x: 0 * spacing, y: 4 * spacing)
        ]

        let basePosition = CGPoint(x:160, y: 5 * spacing)
        let overlayOffset = CGPoint(x: 0, y: 0)

        self.goatPositions = (0..<20).map { index in
            let xOffset = CGFloat(index) * overlayOffset.x
            let yOffset = CGFloat(index) * overlayOffset.y
            return CGPoint(x: basePosition.x + xOffset, y: basePosition.y + yOffset)
        }
    }

    func convertToGridPoint(_ point: CGPoint) -> Point {
        let x = Int(round(point.x / spacing))
        let y = Int(round(point.y / spacing))
        return Point(x: x + 1, y: y + 1)
    }

    func convertToCGPoint(_ point: Point) -> CGPoint {
        let x = CGFloat(point.x - 1) * spacing
        let y = CGFloat(point.y - 1) * spacing
        return CGPoint(x: x, y: y)
    }

    
    func isPointWithinBoard(_ point: CGPoint) -> Bool {
        (0 <= point.x && point.x <= spacing * CGFloat(columns - 1)) &&
        (0 <= point.y && point.y <= spacing * CGFloat(rows - 1))
    }
    
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
        guard isPointWithinBoard(newPos) else { return false }

        if goatsPlaced >= 20 {
            let currentGridPoint = convertToGridPoint(currentPos)
            let newGridPoint = convertToGridPoint(newPos)

            guard let connectedPoints = connectedPointsDict[currentGridPoint] else { return false }

            let isAdjacent = connectedPoints.contains(newGridPoint)
            let isFree = isIntersectionFree(newPos)
            return isAdjacent && isFree
        } else {
            if isPointWithinBoard(currentPos) {
                return false
            }
            return isIntersectionFree(newPos)
        }
    }
}

extension BaghChalGame {

    func canTigerCapture(from currentPos: CGPoint, to newPos: CGPoint) -> Bool {
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)

        print("Checking capture from \(currentGridPoint) to \(newGridPoint)")

        guard let specialCaptureMoves = baghSpecialCaptureMovesDict[currentGridPoint] else {
            print("No special capture moves from this point")
            return false
        }

        if !specialCaptureMoves.contains(newGridPoint) {
            print("The move is not a special capture move")
            return false
        }

        let midGridPoint = Point(x: (currentGridPoint.x + newGridPoint.x) / 2, y: (currentGridPoint.y + newGridPoint.y) / 2)
        let midPoint = convertToCGPoint(midGridPoint)

        let isMidpointOccupiedByGoat = goatPositions.contains(midPoint)
        let isNewPositionFree = isIntersectionFree(newPos)

        print("Midpoint: \(midGridPoint), occupied by goat: \(isMidpointOccupiedByGoat), new position free: \(isNewPositionFree)")

        return isMidpointOccupiedByGoat && isNewPositionFree
    }

    func performTigerCapture(from currentPos: CGPoint, to newPos: CGPoint) {
        let currentGridPoint = convertToGridPoint(currentPos)
        let newGridPoint = convertToGridPoint(newPos)
        let midGridPoint = Point(x: (currentGridPoint.x + newGridPoint.x) / 2, y: (currentGridPoint.y + newGridPoint.y) / 2)

        let midPoint = convertToCGPoint(midGridPoint)

        if let index = goatPositions.firstIndex(of: midPoint) {
            goatPositions.remove(at: index)
            goatsCaptured += 1
        }

        if let tigerIndex = tigerPositions.firstIndex(of: currentPos) {
            tigerPositions[tigerIndex] = newPos
        }

        updateGameState()
    }
    
    func winner() -> String {
        if baghsTrapped == 4 {
            return "G"
        } else if goatsCaptured >= 5 {
            return "B"
        } else {
            return ""
        }
    }
    
        func simulateMove(_ move: Move) -> BaghChalGame {
            let simulatedGame = self.deepCopy()

            let currentPosition = simulatedGame.convertToCGPoint(move.from)
            let newPosition = simulatedGame.convertToCGPoint(move.to)
            
            if simulatedGame.nextTurn == "G" {
                if simulatedGame.goatsPlaced < 20 {
                    simulatedGame.goatPositions.append(newPosition)
                    simulatedGame.goatsPlaced += 1
                } else {
                    if let index = simulatedGame.goatPositions.firstIndex(of: currentPosition) {
                        simulatedGame.goatPositions[index] = newPosition
                    }
                }
            } else if simulatedGame.nextTurn == "B" {
                if let index = simulatedGame.tigerPositions.firstIndex(of: currentPosition) {
                    simulatedGame.tigerPositions[index] = newPosition
                    if canTigerCapture(from: currentPosition, to: newPosition) {
                        performTigerCapture(from: currentPosition, to: newPosition)
                    }
                }
            }

            simulatedGame.updateGameState()

            simulatedGame.nextTurn = simulatedGame.nextTurn == "G" ? "B" : "G"
            
            return simulatedGame
        }
    

    func possibleMoves() -> [Move] {
        var moves: [Move] = []
        var captureMoveFound = false

        if nextTurn == "G" {
            if goatsPlaced < 20 {
                for x in 1...rows {
                    for y in 1...columns {
                        let point = Point(x: x, y: y)
                        if isIntersectionFree(convertToCGPoint(point)) {
                            moves.append(Move(from: point, to: point)) // Placing goats
                        }
                    }
                }
            } else {
                for position in goatPositions {
                    let gridPoint = convertToGridPoint(position)
                    addGoatMoves(from: gridPoint, to: &moves)
                }
            }
        } else if nextTurn == "B" {
            for position in tigerPositions {
                let gridPoint = convertToGridPoint(position)
                addTigerMoves(from: gridPoint, to: &moves)
                if moves.contains(where: { canTigerCapture(from: convertToCGPoint($0.from), to: convertToCGPoint($0.to)) }) {
                    captureMoveFound = true
                    break
                }
            }
        }

        if captureMoveFound {
            moves = moves.filter { canTigerCapture(from: convertToCGPoint($0.from), to: convertToCGPoint($0.to)) }
        }

        return moves
    }


    func addTigerMoves(from gridPoint: Point, to moves: inout [Move]) {
        if let specialCaptureMoves = baghSpecialCaptureMovesDict[gridPoint] {
            for point in specialCaptureMoves {
                let newPos = convertToCGPoint(point)
                if canTigerCapture(from: convertToCGPoint(gridPoint), to: newPos) {
                    moves.append(Move(from: gridPoint, to: point))
                    return
                }
            }
        }

        if let connectedPoints = connectedPointsDict[gridPoint] {
            for point in connectedPoints {
                let newPos = convertToCGPoint(point)
                if isIntersectionFree(newPos) {
                    moves.append(Move(from: gridPoint, to: point))
                }
            }
        }
    }
    
    func addGoatMoves(from gridPoint: Point, to moves: inout [Move]) {
        if let connectedPoints = connectedPointsDict[gridPoint] {
            for point in connectedPoints {
                if isIntersectionFree(convertToCGPoint(point)) {
                    moves.append(Move(from: gridPoint, to: point))
                }
            }
        }
    }
    
    func applyTigerMove(_ move: Move) {
 
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)
        
        if nextTurn == "B" {
            if let index = self.tigerPositions.firstIndex(of: currentPosition) {
                self.tigerPositions[index] = newPosition
                if self.canTigerCapture(from: currentPosition, to: newPosition) {
                    self.performTigerCapture(from: currentPosition, to: newPosition)
                }
            }
        }

        self.updateGameState()
        self.nextTurn = "G"
    }
    
    func applyGoatMove(_ move: Move) {
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)

        if nextTurn == "G" {
            if goatsPlaced < 20 {
                if isIntersectionFree(newPosition) {
                    self.goatPositions.append(newPosition)
                    self.goatsPlaced += 1
                }
            } else {
                if let index = self.goatPositions.firstIndex(of: currentPosition) {
                    if isValidGoatMove(from: currentPosition, to: newPosition) {
                        self.goatPositions[index] = newPosition
                    }
                }
            }
        }

        self.updateGameState()
        self.nextTurn = "B"
    }
    
    func bestMoveForTigers() -> Move? {
        guard nextTurn == "B" else { return nil }

        var bestScore = -Double.infinity
        var bestMove: Move?

        for move in possibleMoves() {
            let simulatedGame = simulateMove(move)
            let score = engine.minimax(game: simulatedGame, depth: engine.depth, alpha: -engine.INF, beta: engine.INF, maximizingPlayer: true)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }
 
    func bestMoveForGoats() -> Move? {
        guard nextTurn == "G" else { return nil }

        var bestScore = Double.infinity
        var bestMove: Move?

        for move in possibleMoves() {
            let simulatedGame = simulateMove(move)
            let score = engine.minimax(game: simulatedGame, depth: engine.depth, alpha: -engine.INF, beta: engine.INF, maximizingPlayer: false)
            if score < bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }
    
    func deepCopy() -> BaghChalGame {
        let copiedGame = BaghChalGame(spacing: self.spacing,
                                      rows: self.rows,
                                      columns: self.columns,
                                      diameter: self.diameter,
                                      connectedPointsDict: self.connectedPointsDict,
                                      baghSpecialCaptureMovesDict: self.baghSpecialCaptureMovesDict,
                                      engine: self.engine.deepCopy())
        
        copiedGame.baghsTrapped = self.baghsTrapped
        copiedGame.goatsCaptured = self.goatsCaptured
        copiedGame.nextTurn = self.nextTurn
        copiedGame.goatsPlaced = self.goatsPlaced
        copiedGame.tigerPositions = self.tigerPositions
        copiedGame.goatPositions = self.goatPositions
        copiedGame.isGameOver = self.isGameOver
        copiedGame.winningSide = self.winningSide
        copiedGame.trappedTigers = Set(self.trappedTigers)
        
        return copiedGame
    }
}

extension BaghChalGame {
    func isGoatSafe(at point: Point) -> Bool {
        for tigerPos in tigerPositions {
            let tigerGridPoint = convertToGridPoint(tigerPos)
            if let connectedPoints = connectedPointsDict[tigerGridPoint], connectedPoints.contains(point) {
                let direction = Point(x: point.x - tigerGridPoint.x, y: point.y - tigerGridPoint.y)
                let oppositePoint = Point(x: point.x + direction.x, y: point.y + direction.y)
                if isPointWithinBoard(convertToCGPoint(oppositePoint)) && isIntersectionFree(convertToCGPoint(oppositePoint)) {
                    return false
                }
            }
        }
        return true
    }

    func isGoatUnderThreat(at point: Point) -> Bool {
        for tigerPos in tigerPositions {
            let tigerGridPoint = convertToGridPoint(tigerPos)
            if let connectedPoints = connectedPointsDict[tigerGridPoint], connectedPoints.contains(point) {
                let direction = Point(x: point.x - tigerGridPoint.x, y: point.y - tigerGridPoint.y)
                let oppositePoint = Point(x: point.x + direction.x, y: point.y + direction.y)
                if isPointWithinBoard(convertToCGPoint(oppositePoint)) && isIntersectionFree(convertToCGPoint(oppositePoint)) {
                    return true
                }
            }
        }
        return false
    }
        
    func processReceivedMove(_ move: Move) {
        if nextTurn == "G" {
            applyGoatMove(move)
        } else if nextTurn == "B" {
            applyTigerMove(move)
        }
    }
}



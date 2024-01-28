//
//  GameService.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import Foundation
import SwiftUI
import Combine

class GameService: ObservableObject {
    @Published var player1 = Player(gamePiece: .goat, name: "Player 1")
    @Published var player2 = Player(gamePiece: .tiger, name: "Player 2")
    @Published var possibleMoves: [Move] = []
    @Published var gameOver: Bool = false


    @Published var baghsTrapped: Int = 0
    @Published var goatsCaptured: Int = 0
//    @Published var nextTurn: String = "G" // or "B"
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

    var currentPlayer: Player {
        player1.isCurrent ? player1 : player2
    }

    var gameStarted: Bool {
        player1.isCurrent || player2.isCurrent
    }

    var gameType = GameType.undetermined

    func setupGame(gameType: GameType, player1Name: String, player2Name: String) {
        switch gameType {
        case .single:
            self.gameType = .single
        case .bot:
            self.gameType = .bot
        case .peer:
            self.gameType = .peer
        case .undetermined:
            break
        }
        player1.name = player1Name
    }

    func resetGame() {
        baghsTrapped = 0
        goatsCaptured = 0
        goatsPlaced = 0
        gameOver = false
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
        player1.isCurrent = true
        player2.isCurrent = false
    }

    func toggleCurrentPlayer() {
        player1.isCurrent.toggle()
        player2.isCurrent.toggle()
    }

    init(spacing: CGFloat, rows: Int, columns: Int, diameter: CGFloat, connectedPointsDict: [Point: Set<Point>], baghSpecialCaptureMovesDict: [Point: Set<Point>]) {

        self.spacing = spacing
        self.rows = rows
        self.columns = columns
        self.diameter = diameter
        self.connectedPointsDict = connectedPointsDict
        self.baghSpecialCaptureMovesDict = baghSpecialCaptureMovesDict

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
            gameOver = true
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

extension GameService {

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

    func updatePossibleMoves() {
        var newMoves: [Move] = []

        if player1.isCurrent {
            if goatsPlaced < 20 {
                for x in 1...rows {
                    for y in 1...columns {
                        let point = Point(x: x, y: y)
                        if isIntersectionFree(convertToCGPoint(point)) {
                            newMoves.append(Move(from: point, to: point)) // Placing goats
                        }
                    }
                }
            } else {
                for position in goatPositions {
                    let gridPoint = convertToGridPoint(position)
                    addGoatMoves(from: gridPoint, to: &newMoves)
                }
            }
        } else if player2.isCurrent {
            for position in tigerPositions {
                let gridPoint = convertToGridPoint(position)
                addTigerMoves(from: gridPoint, to: &newMoves)
            }
        }
        self.possibleMoves = newMoves
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

    func makeTigerMove(_ move: Move) {
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)

        // ISSUE MAY BE BECAUSE move.from and move.to ma there is same value 
        if player2.isCurrent {
            if canTigerCapture(from: currentPosition, to: newPosition) {
                performTigerCapture(from: currentPosition, to: newPosition)
            } else if isValidTigerMove(from: currentPosition, to: newPosition) {
                if let index = self.tigerPositions.firstIndex(of: currentPosition) {
                    self.tigerPositions[index] = newPosition
                }
            }

            updateGameState()
            toggleCurrentPlayer()
        }
    }

    func makeGoatMove(_ move: Move) {
        let currentPosition = self.convertToCGPoint(move.from)
        let newPosition = self.convertToCGPoint(move.to)

        if player1.isCurrent {
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
        toggleCurrentPlayer()
    }
}

extension GameService {
    func processReceivedMove(_ move: Move) {
        if player1.isCurrent {
            makeGoatMove(move)
        } else if player2.isCurrent {
            makeTigerMove(move)
        }
    }
}



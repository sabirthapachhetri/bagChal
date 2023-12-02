//
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
    @Published var fenCount: [String: Int] = [:]
    @Published var baghPoints: Set<Point> = []
    @Published var goatPoints: Set<Point> = []
    @Published var noOfGoatMoves: Int = 0
    @Published var baghs: [Bagh] = []
    @Published var goats: [Goat] = []

    var initialTigerPositions: [CGPoint]
    var initialGoatPositions: [CGPoint]

    init(spacing: CGFloat) {
        // Initialize tiger positions based on the spacing
        initialTigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),       // Top-left
            CGPoint(x: 4 * spacing, y: 0 * spacing),       // Top-right
            CGPoint(x: 4 * spacing, y: 4 * spacing),       // Bottom-right
            CGPoint(x: 0 * spacing, y: 4 * spacing)        // Bottom-left
        ]
        
        // Initialize goat positions in a holding area
        initialGoatPositions = (0..<20).map { index in
            // This assumes a horizontal layout below the board for holding goats
            let row = CGFloat(index / 5) // 5 goats per row in the holding area
            let col = CGFloat(index % 5) // Column in the holding area
            return CGPoint(x: col * spacing, y: (5 + row) * spacing) // Adjust '5' based on your board's bottom y-position
        }
    }

    // Convert FEN to board state
    private func fenToBoard(_ fen: String) {
        let rows = fen.split(separator: " ")[0].split(separator: "/")
        for (x, row) in rows.enumerated() {
            var counter = 1
            for y in row {
                if y == "B" {
                    let bagh = Bagh(position: Point(x: x + 1, y: counter), board: self)
                    baghs.append(bagh) // Assuming you have an array of Baghs
                    baghPoints.insert(Point(x: x + 1, y: counter)) // Track Bagh points
                    counter += 1
                } else if y == "G" {
                    let goat = Goat(position: Point(x: x + 1, y: counter), board: self)
                    goatPoints.insert(Point(x: x + 1, y: counter)) // Track Goat points
                    counter += 1
                } else if let number = Int(String(y)) {
                    counter += number
                }
            }
        }
    }
    
    subscript(x: Int, y: Int) -> Piece? {
        get {
            let point = Point(x: x, y: y)
            if baghPoints.contains(point) {
                return Bagh(position: point, board: self)
            } else if goatPoints.contains(point) {
                return Goat(position: point, board: self)
            } else {
                return nil
            }
        }
    }

    // method to determine if the game is over
    func isGameOver() -> Bool {
        if goatsCaptured >= 5 || baghsTrapped == 4 || checkDraw() || allGoatsTrapped() {
            return true
        }
        return false
    }
    
    // Check if all goats are trapped
    private func allGoatsTrapped() -> Bool {
        return nextTurn == "G" && possibleGoatMoves().isEmpty
    }

    // Check for a draw
    private func checkDraw() -> Bool {
        if let maxCount = fenCount.values.max(), maxCount >= 3 {
            return true
        }
        return false
    }
    
    // Function to get possible goat moves
    func possibleGoatMoves() -> Set<String> {
        var moveList = Set<String>()

        if noOfGoatMoves < 20 {
            // Before 20 goat moves, return all empty points
            for x in 1...5 {
                for y in 1...5 {
                    let point = Point(x: x, y: y)
                    if !baghPoints.contains(point) && !goatPoints.contains(point) {
                        moveList.insert("G\(x)\(y)")
                    }
                }
            }
        } else {
            // After 20 moves, goats can move to adjacent valid positions
            for point in goatPoints {
                let validMoves = point.validMoves() // Implement this based on your game logic
                moveList = moveList.union(validMoves.map { move in
                    "G\(point.x)\(point.y)\(move.x)\(move.y)"
                })
            }
        }

        return moveList
    }
    
    // Method to determine the winner
    func winner() -> String? {
        if goatsCaptured >= 5 || allGoatsTrapped() {
            return "B"
        }
        if baghsTrapped == 4 {
            return "G"
        }
        if checkDraw() {
            return "Draw"
        }
        return nil
    }
    
    // Function to get possible bagh moves
    func possibleBaghMoves() -> Set<String> {
        var moveList = Set<String>()

        for bagh in baghs {
            let validRegularMoves = bagh.validNonSpecialMoves()
            for validMove in validRegularMoves {
                moveList.insert("B\(bagh.position.x)\(bagh.position.y)\(validMove.x)\(validMove.y)")
            }

            let validCapturingMoves = bagh.validBaghMoves()
            for validCapture in validCapturingMoves {
                moveList.insert("Bx\(bagh.position.x)\(bagh.position.y)\(validCapture.x)\(validCapture.y)")
            }
        }

        return moveList
    }
    
    // Method to get all possible moves
    func possibleMoves() -> [Move] {
        var moves: [Move] = []

        if isGameOver() {
            return moves
        }

        if nextTurn == "G" {
            for moveString in possibleGoatMoves() {
                let move = stringToMove(moveString)
                moves.append(move)
            }
        } else {
            for moveString in possibleBaghMoves() {
                let move = stringToMove(moveString)
                moves.append(move)
            }
        }

        return moves
    }

    // Convert a move string to Move structure
    private func stringToMove(_ moveString: String) -> Move {
        let characters = Array(moveString)
        
        let fromX = Int(String(characters[1]))!
        let fromY = Int(String(characters[2]))!

        let toX: Int
        let toY: Int

        if moveString.count == 5 {
            toX = Int(String(characters[3]))!
            toY = Int(String(characters[4]))!
            return Move(from: Point(x: fromX, y: fromY), to: Point(x: toX, y: toY))
        } else {
            // For placing goats (no 'from' position)
            toX = fromX
            toY = fromY
            return Move(from: nil, to: Point(x: toX, y: toY))
        }
    }

    // Method to execute a move
    func move(_ move: Move) {
        // Implement logic to update the game state based on a move
    }

    // Method to create a copy of the game state
    func copy() -> BaghChalGame {
        let newGame = BaghChalGame(spacing: 80)
        // Implement logic to create and return a copy of the current game state
        return newGame
    }
}

// Define the Move structure
struct Move {
    // Properties of a move
    let from: Point?
    let to: Point

    // Initializer for different scenarios
    init(from: Point? = nil, to: Point) {
        self.from = from
        self.to = to
    }
}

struct Point: Hashable {
    var x: Int
    var y: Int

    func validMoves() -> Set<Point> {
        // Assuming a standard Bagh-Chal board layout
        // You will need to adjust this to your game's specific layout
        let adjacentPoints = [
            Point(x: x + 1, y: y), Point(x: x - 1, y: y),
            Point(x: x, y: y + 1), Point(x: x, y: y - 1),
            Point(x: x + 1, y: y + 1), Point(x: x - 1, y: y - 1),
            Point(x: x + 1, y: y - 1), Point(x: x - 1, y: y + 1)
        ]

        // Filter out points that are not on the board
        return Set(adjacentPoints.filter { $0.isOnBoard })
    }

    var isOnBoard: Bool {
        return (1...5).contains(x) && (1...5).contains(y)
    }
}

class Piece {
    var position: Point
    weak var board: BaghChalGame?

    init(position: Point, board: BaghChalGame) {
        self.position = position
        self.board = board
    }

    // Connected points method
    func connectedPoints() -> Set<Point> {
        var points = Set<Point>()

        // Adjacent points including diagonals
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        for (dx, dy) in directions {
            let adjacentPoint = Point(x: position.x + dx, y: position.y + dy)
            if adjacentPoint.isOnBoard {
                points.insert(adjacentPoint)
            }
        }
        return points
    }
}

class Bagh: Piece {
    // Initializer and other methods
    
    // Non-special valid moves
    func validNonSpecialMoves() -> Set<Point> {
        var validMoves = Set<Point>()
        for point in connectedPoints() {
            if board?[point.x, point.y] == nil { // Check if the point is not occupied
                validMoves.insert(point)
            }
        }
        return validMoves
    }
    
    // Special valid moves for capturing goats
    func validBaghMoves() -> Set<Point> {
        var validMoves = Set<Point>()
        for point in specialConnectedPoints() { // Implement this method to get special connected points
            let midPoint = Point(x: (point.x + position.x) / 2, y: (point.y + position.y) / 2)
            if let midPiece = board?[midPoint.x, midPoint.y] as? Goat, board?[point.x, point.y] == nil {
                validMoves.insert(point)
            }
        }
        return validMoves
    }
    
    private func specialConnectedPoints() -> Set<Point> {
        var points = Set<Point>()

        // Directions for special moves (capturing)
        let captureDirections = [(-2, -2), (-2, 0), (-2, 2), (0, -2), (0, 2), (2, -2), (2, 0), (2, 2)]
        for (dx, dy) in captureDirections {
            let targetPoint = Point(x: position.x + dx, y: position.y + dy)
            let midPoint = Point(x: position.x + dx / 2, y: position.y + dy / 2)
            if targetPoint.isOnBoard,
               let midPiece = board?[midPoint.x, midPoint.y] as? Goat,
               board?[targetPoint.x, targetPoint.y] == nil {
                points.insert(targetPoint)
            }
        }

        return points
    }
}

class Goat: Piece {
    // Initializer
    override init(position: Point, board: BaghChalGame) {
        super.init(position: position, board: board)
    }

    // Valid moves for a Goat
    func validMoves() -> Set<Point> {
        var validMoves = Set<Point>()

        // Goats can move to adjacent points if they are empty
        for point in connectedPoints() {
            if board?[point.x, point.y] == nil { // Check if the point is not occupied
                validMoves.insert(point)
            }
        }

        return validMoves
    }

    // Override the connectedPoints method to return adjacent points
    override func connectedPoints() -> Set<Point> {
        let adjacentPoints = [
            Point(x: position.x + 1, y: position.y),
            Point(x: position.x - 1, y: position.y),
            Point(x: position.x, y: position.y + 1),
            Point(x: position.x, y: position.y - 1),
            // Diagonal moves can be included or excluded based on your game rules
        ]

        // Filter out points that are not on the board
        return Set(adjacentPoints.filter { $0.isOnBoard })
    }
}

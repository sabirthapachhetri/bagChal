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
    let spacing: CGFloat = 80
    let lineWidth: CGFloat = 2
    let intersectionCircleDiameter: CGFloat = 40 
    
    // State variables for draggable pieces
    @State private var goatPositions: [CGPoint]
    @State private var tigerPositions: [CGPoint]
    
    @State private var game: BaghChalGame
    private var engine = Engine()
    
    init() {
        _goatPositions = State(initialValue: Array(repeating: .zero, count: 20))
        
        // Initialize the game logic
        let gameLogic = BaghChalGame(spacing: spacing)
        _game = State(initialValue: gameLogic)

        // Initialize tigerPositions using the game logic
        _goatPositions = State(initialValue: gameLogic.initialGoatPositions)
        _tigerPositions = State(initialValue: gameLogic.initialTigerPositions)
    }
    
    var body: some View {
        VStack {
            ZStack {
                GridDrawing(rows: rows, columns: columns, spacing: spacing, lineWidth: lineWidth)
                IntersectionCircles(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter)
                TigerPiece(tigerPositions: $tigerPositions, rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter)
                GoatPiece(goatPositions: $goatPositions, tigerPositions: $tigerPositions, rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter)
            }
            .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
            .padding(spacing)
        }
    }
}

struct BagChalBoard_Previews: PreviewProvider {
    static var previews: some View {
        BaghChalBoard()
    }
}

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

    let connectedPoints = connectedPointsDict // Assuming this is initialized somewhere

    @StateObject private var game: BaghChalGame

    init() {
        // Initialize the game logic with required parameters
        let gameLogic = BaghChalGame(spacing: spacing, rows: rows, columns: columns, diameter: intersectionCircleDiameter, connectedPointsDict: connectedPoints)
        _game = StateObject(wrappedValue: gameLogic)
    }

    var body: some View {
        VStack {
            GameStatusHeaderView(baghsTrapped: $game.baghsTrapped, goatsCaptured: $game.goatsCaptured, game: game)

            ZStack {
                GridDrawing(rows: rows, columns: columns, spacing: spacing, lineWidth: lineWidth)

                IntersectionCircles(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, connectedPointsDict: connectedPoints)

                TigerPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: game)

                GoatPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: game)
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

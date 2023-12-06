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

    @StateObject private var game = BaghChalGame(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict)
    @State private var showAlert = false

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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("Goats have won the game!"),
                dismissButton: .default(Text("Restart")) {
                    game.resetGame()
                }
            )
        }
        .onChange(of: game.baghsTrapped) { newValue in
            if newValue == 4 {
                showAlert = true
            }
        }
    }
}

struct BagChalBoard_Previews: PreviewProvider {
    static var previews: some View {
        BaghChalBoard()
    }
}

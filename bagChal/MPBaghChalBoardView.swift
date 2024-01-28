//
//  MPBaghChalBoardView.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import SwiftUI

struct MPBaghChalBoardView: View {
    let columns = 5
    let rows = 5
    let spacing: CGFloat = 80
    let lineWidth: CGFloat = 2
    let intersectionCircleDiameter: CGFloat = 40
    let connectedPoints = connectedPointsDict
    let baghSpecialCaptureMoves = baghSpecialCaptureMovesDict

    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 10) {
            MPGameStatusHeaderView(baghsTrapped: $game.baghsTrapped, goatsCaptured: $game.goatsCaptured, game: game)
                .padding(.bottom, -60) 

            ZStack {
                GridDrawing(rows: rows, columns: columns, spacing: spacing, lineWidth: lineWidth)

                IntersectionCircles(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, connectedPointsDict: connectedPoints)

                MPTigerPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: _game)

                MPGoatPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: _game)
            }
            .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
            .padding(spacing)
        }
        .alert(isPresented: $showAlert) {
            if game.goatsCaptured >= 5 {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Tigers have won the game!"),
                    dismissButton: .default(Text("Restart")) {
                        game.resetGame()
                    }
                )
            } else {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Goats have won the game!"),
                    dismissButton: .default(Text("Restart")) {
                        game.resetGame()
                    }
                )
            }
        }
        .onChange(of: game.goatsCaptured) { newValue in
            if newValue >= 5 {
                showAlert = true
            }
        }
        .onChange(of: game.baghsTrapped) { newValue in
            if newValue == 4 {
                showAlert = true
            }
        }
    }
}

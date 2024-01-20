//
//  BagChalBoard.swift
//  bagChal
//
//  Created by Sabir Thapa on 26/11/2023.
//

import SwiftUI

struct BaghChalBoard: View {
    let userRole: PlayerRole?
    let playAgainstAI: Bool // Add this
    let columns = 5
    let rows = 5
    let spacing: CGFloat = 80
    let lineWidth: CGFloat = 2
    let intersectionCircleDiameter: CGFloat = 40

    let connectedPoints = connectedPointsDict
    let baghSpecialCaptureMoves = baghSpecialCaptureMovesDict
    
    var isAIGoat: Bool {
        playAgainstAI && userRole == .tiger
    }

    var isAITiger: Bool {
        playAgainstAI && userRole == .goat
    }

    @StateObject private var game = BaghChalGame(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict, baghSpecialCaptureMovesDict: baghSpecialCaptureMovesDict)
    @State private var showAlert = false

    var body: some View {
        VStack {
            GameStatusHeaderView(baghsTrapped: $game.baghsTrapped, goatsCaptured: $game.goatsCaptured, game: game)

            ZStack {
                GridDrawing(rows: rows, columns: columns, spacing: spacing, lineWidth: lineWidth)

                IntersectionCircles(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, connectedPointsDict: connectedPoints)

                TigerPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: game, isAITiger: isAITiger)

                GoatPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $game.goatPositions, tigerPositions: $game.tigerPositions, game: game, isAIGoat: isAIGoat)
            }
            .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
            .padding(spacing)
        }
        .alert(isPresented: $showAlert) {
            if game.goatsCaptured >= 5 {
                // Alert for Tiger's win
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Tigers have won the game!"),
                    dismissButton: .default(Text("Restart")) {
                        game.resetGame()
                    }
                )
            } else {
                // Alert for Goat's win
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

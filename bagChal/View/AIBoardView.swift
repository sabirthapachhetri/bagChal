//
//  AIBoardView.swift
//  bagChal
//
//  Created by Sabir Thapa on 26/11/2023.
//

import SwiftUI

struct AIBoardView: View {
    let userRole: PlayerRole?
    let playAgainstAI: Bool // Add this
    let columns = 5
    let rows = 5
    let spacing: CGFloat = 80
    let lineWidth: CGFloat = 2
    let intersectionCircleDiameter: CGFloat = 40

    let connectedPoints = connectedPointsDict
    let baghSpecialCaptureMoves = baghSpecialCaptureMovesDict
    @ObservedObject var aiGame: BaghChalGame
    
    var gameType: GameType = .undetermined
    @EnvironmentObject var mpConnectionManager: MPConnectionManager
    @State private var startGame = false

    
    var isAIGoat: Bool {
        playAgainstAI && userRole == .tiger
    }

    var isAITiger: Bool {
        playAgainstAI && userRole == .goat
    }

    @State private var showAlert = false

    var body: some View {
        VStack {
            GameStatusHeaderView(baghsTrapped: $aiGame.baghsTrapped, goatsCaptured: $aiGame.goatsCaptured, game: aiGame)

            ZStack {
                GridDrawing(rows: rows, columns: columns, spacing: spacing, lineWidth: lineWidth)

                IntersectionCircles(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, connectedPointsDict: connectedPoints)

                TigerPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $aiGame.goatPositions, tigerPositions: $aiGame.tigerPositions, game: aiGame, isAITiger: isAITiger)

                GoatPiece(rows: rows, columns: columns, spacing: spacing, diameter: intersectionCircleDiameter, goatPositions: $aiGame.goatPositions, tigerPositions: $aiGame.tigerPositions, game: aiGame, isAIGoat: isAIGoat)
            }
            .frame(width: spacing * CGFloat(columns - 1), height: spacing * CGFloat(rows - 1))
            .padding(spacing)
        }
        .alert(isPresented: $showAlert) {
            if aiGame.goatsCaptured >= 5 {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Tigers have won the game!"),
                    dismissButton: .default(Text("Restart")) {
                        aiGame.resetGame()
                    }
                )
            } else {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Goats have won the game!"),
                    dismissButton: .default(Text("Restart")) {
                        aiGame.resetGame()
                    }
                )
            }
        }
        .onChange(of: aiGame.goatsCaptured) { newValue in
            if newValue >= 5 {
                showAlert = true
            }
        }
        .onChange(of: aiGame.baghsTrapped) { newValue in
            if newValue == 4 {
                showAlert = true
            }
        }
    }
}

//
//  GameView.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var messagesManager: MessagesManager // Add this line
    @Environment(\.dismiss) var dismiss
    @State private var isShowingMessages = false
    var body: some View {
        VStack {
            if [game.player1.isCurrent, game.player2.isCurrent].allSatisfy{ $0 == false} {
                Text("Select a player to start")
            }
            HStack {
                Button(game.player1.name) {
                    game.player1.isCurrent = true
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .start, playerName: game.player1.name, move: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(PlayerButtonStyle(player: game.player1))
                Button(game.player2.name) {
                    game.player2.isCurrent = true
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .start, playerName: game.player2.name, move: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(PlayerButtonStyle(player: game.player2))
            }
            .disabled(game.gameStarted)
            VStack {
                MPBaghChalBoardView()
            }
            .disabled(game.gameType == .peer &&
                      connectionManager.myPeerId.displayName != game.currentPlayer.name)
            VStack {
                if game.gameOver {
                    Text("Game Over")
                    if game.possibleMoves.isEmpty {
                        Text("Nobody wins")
                    } else {
                        Text("\(game.currentPlayer.name) wins!")
                    }
                    Button("New Game") {
                        game.resetGame()
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .reset, playerName: nil, move: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .font(.largeTitle)
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("End Game") {
                    dismiss()
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .end, playerName: nil, move: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(.bordered)

                Button(action: {
                    isShowingMessages = true
                }) {
                    Image(systemName: "bubble.right")
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("BaghChal")
        .onAppear {
            game.resetGame()
            if game.gameType == .peer {
                connectionManager.setup(game: game)
            }
        }
        .inNavigationStack()
        .sheet(isPresented: $isShowingMessages) {
            MessageView()
                .environmentObject(messagesManager) 
        }
    }
}

struct PlayerButtonStyle: ButtonStyle {
    let player: Player
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(player.isCurrent ? Color.green : Color.gray)
            )
            .foregroundColor(.white)
        
    }
}

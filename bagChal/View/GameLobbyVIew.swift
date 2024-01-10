//
//  GameLobbyVIew.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/01/2024.
//

import SwiftUI
import Firebase

import SwiftUI
import Firebase

struct GameLobbyView: View {
    @EnvironmentObject var viewModel: GameLobbyViewModel
    @State private var selectedGame: GameSession?
    @State private var navigateToGameBoard = false


    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView() // Show a loading indicator while fetching games
                } else {
                    ForEach(viewModel.availableGames) { game in
                        HStack {
                            VStack(alignment: .leading) {
                                // Display player info here, for example:
                                Text("Game ID: \(game.gameId)")
                                Text("Player 1: \(game.player1Id)")
                                Text("Player 2: \(game.player2Id)")
                            }
                            Spacer()
                            Button(action: {
                                // This could either create a new game or join the existing one
                                // depending on your specific app logic
                                createOrJoinGame(game)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Game Lobby")
            .onAppear {
                viewModel.fetchAvailableGames()
            }
        }
        .background(
            NavigationLink(destination: BaghChalBoard(userRole: nil, playAgainstAI: false),
                           isActive: $navigateToGameBoard) {
                EmptyView()
            }
        )
    }
    
    private func createOrJoinGame(_ game: GameSession) {
        // Get the current user's ID
        guard let playerId = Auth.auth().currentUser?.uid else {
            print("User must be signed in to create or join a game")
            // Handle the error, maybe show an alert or perform some UI action
            return
        }
        
        // Decide whether to create a new game or join an existing one
        if game.player1Id.isEmpty {
            // If player1Id is empty, it means no game is created, so create a new one
            viewModel.createNewGame(playerId: playerId)
        } else {
            // If there is a player1Id, then join the game as player 2
            viewModel.joinGame(game) { success in
                if success {
                    self.selectedGame = game
                    self.navigateToGameBoard = true
                } else {
                    // Handle the error, show an alert or message to the user
                }
            }
        }
    }

}

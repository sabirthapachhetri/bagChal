//
//  GameLobbyVIew.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/01/2024.
//

import SwiftUI
import Firebase

struct GameLobbyView: View {
    @EnvironmentObject var viewModel: GameLobbyViewModel // Assuming this is passed as an environment object

    var body: some View {
        NavigationView {
            List(viewModel.availableGames) { game in
                Text(game.id)
                // Add additional game info here
            }
            .navigationTitle("Available Games")
            .toolbar {
                Button("Create Game") {
                    viewModel.createNewGame(playerId: Auth.auth().currentUser?.uid ?? "")
                }
            }
            .onAppear {
                viewModel.fetchAvailableGames()
            }
        }
    }
}


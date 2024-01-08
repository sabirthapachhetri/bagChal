//
//  GameLobbyViewModel.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/01/2024.
//

import Foundation
import Firebase

class GameLobbyViewModel: ObservableObject {
    @Published var availableGames: [GameSession] = []
    @Published var isLoading = false
    private var db = Firestore.firestore()

    init() {
        fetchAvailableGames()
    }

    func fetchAvailableGames() {
        isLoading = true
        db.collection("games").whereField("isComplete", isEqualTo: false).getDocuments { [weak self] (querySnapshot, err) in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No games found")
                return
            }
            
            let games = documents.map { (document) -> GameSession in
                let data = document.data()
                let gameId = document.documentID  // Using the documentID as the gameId
                let player1Id = data["player1Id"] as? String ?? ""
                let player2Id = data["player2Id"] as? String ?? ""
                let boardState = data["boardState"] as? [String] ?? []
                let turn = data["turn"] as? String ?? ""
                let isComplete = data["isComplete"] as? Bool ?? false
                let winner = data["winner"] as? String ?? ""
                
                return GameSession(gameId: gameId, player1Id: player1Id, player2Id: player2Id, boardState: boardState, turn: turn, isComplete: isComplete, winner: winner)
            }
            
            DispatchQueue.main.async {
                self?.availableGames = games
            }
        }
    }

    func createNewGame(playerId: String) {
        let newGameRef = db.collection("games").document()
        
        newGameRef.setData([
            "player1Id": playerId,
            "player2Id": "",
            "boardState": [],  // Assume an empty array for the initial state
            "turn": "player1",  // Assume player 1 starts the game
            "isComplete": false,
            "winner": ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully created with ID: \(newGameRef.documentID)")
                // Handle successful game creation here, if necessary
            }
        }
    }
}

struct GameSession: Identifiable {
    var id: String { gameId } // This provides a unique identifier for each session
    var gameId: String
    var player1Id: String
    var player2Id: String
    var boardState: [String]
    var turn: String
    var isComplete: Bool
    var winner: String

    // Dictionary representation for Firebase
    var dictionary: [String: Any] {
        return [
            "player1Id": player1Id,
            "player2Id": player2Id,
            "boardState": boardState,
            "turn": turn,
            "isComplete": isComplete,
            "winner": winner
        ]
    }
}

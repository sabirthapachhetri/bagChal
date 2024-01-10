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
    @Published var connectedGame: GameSession?

    init() {
        fetchAvailableGames()
    }

    func fetchAvailableGames() {
        print("Current user ID: \(Auth.auth().currentUser?.uid ?? "No user signed in")")
        isLoading = true
        db.collection("games").whereField("isComplete", isEqualTo: false).getDocuments { [weak self] (querySnapshot, err) in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
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

extension GameLobbyViewModel {
    func joinGame(_ game: GameSession, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, userId != game.player1Id else {
            print("User must be signed in and not the same as player 1 to join a game")
            completion(false)
            return
        }

        // Reference to the game session in Firestore
        let gameRef = db.collection("games").document(game.gameId)

        // Start a Firestore transaction to ensure atomicity
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let gameDocument: DocumentSnapshot
            do {
                try gameDocument = transaction.getDocument(gameRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // Check if there's already a player 2
            if let player2Id = gameDocument.data()?["player2Id"] as? String, !player2Id.isEmpty {
                print("The game is already full.")
                return nil
            }

            // Set the current user as player 2
            transaction.updateData(["player2Id": userId], forDocument: gameRef)
            return nil
        }) { [weak self] (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(false)
            } else {
                print("User joined the game")
                DispatchQueue.main.async {
                    self?.connectedGame = game // Set the connected game
                }
                completion(true)
            }
        }
    }
}


struct GameSession: Identifiable, Equatable {
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

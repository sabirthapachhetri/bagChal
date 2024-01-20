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
    @Published var connectedGame: GameSession?
    private var db = Firestore.firestore()
    private var gameListener: ListenerRegistration?

    init() {
        fetchAvailableGames()
    }

    deinit {
        gameListener?.remove() // Stop listening to changes when the view model is deallocated.
    }

    func fetchAvailableGames() {
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
            let games = documents.compactMap { document -> GameSession? in
                var game = GameSession(gameId: document.documentID, player1Id: "", player2Id: "", boardState: [], turn: "", isComplete: false, winner: "")
                let data = document.data()
                game.player1Id = data["player1Id"] as? String ?? ""
                game.player2Id = data["player2Id"] as? String ?? ""
                game.boardState = data["boardState"] as? [String] ?? []
                game.turn = data["turn"] as? String ?? ""
                game.isComplete = data["isComplete"] as? Bool ?? false
                game.winner = data["winner"] as? String ?? ""
                return game
            }
            DispatchQueue.main.async {
                self?.availableGames = games
            }
        }
    }

    func createNewGame(playerId: String) {
        removeExistingGameFor(playerId: playerId) { [weak self] in
            let newGameRef = self?.db.collection("games").document()
            newGameRef?.setData([
                "player1Id": playerId,
                "player2Id": "",
                "boardState": [],
                "turn": "player1",
                "isComplete": false,
                "winner": ""
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document successfully created with ID: \(newGameRef?.documentID ?? "")")
                    self?.listenToGame(gameId: newGameRef?.documentID ?? "")
                }
            }
        }
    }

    func joinGame(_ game: GameSession, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, userId != game.player1Id else {
            print("User must be signed in and not the same as player 1 to join a game")
            completion(false)
            return
        }

        let gameRef = db.collection("games").document(game.gameId)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let gameDocument: DocumentSnapshot
            do {
                try gameDocument = transaction.getDocument(gameRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            if let player2Id = gameDocument.data()?["player2Id"] as? String, !player2Id.isEmpty {
                print("The game is already full.")
                return nil
            }
            transaction.updateData(["player2Id": userId], forDocument: gameRef)
            return nil
        }) { [weak self] (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(false)
            } else {
                print("User joined the game")
                self?.listenToGame(gameId: game.gameId)
                completion(true)
            }
        }
    }

    func listenToGame(gameId: String) {
        gameListener?.remove() // Stop listening to any previous game.
        gameListener = db.collection("games").document(gameId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching game updates: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                guard let data = snapshot.data() else {
                    print("Game data was empty")
                    return
                }
                
                // Create a GameSession from the Firestore document data
                let updatedGame = GameSession(
                    gameId: snapshot.documentID,
                    player1Id: data["player1Id"] as? String ?? "",
                    player2Id: data["player2Id"] as? String ?? "",
                    boardState: data["boardState"] as? [String] ?? [],
                    turn: data["turn"] as? String ?? "",
                    isComplete: data["isComplete"] as? Bool ?? false,
                    winner: data["winner"] as? String ?? ""
                )
                
                DispatchQueue.main.async {
                    self?.connectedGame = updatedGame
                }
            }
    }

    private func removeExistingGameFor(playerId: String, completion: @escaping () -> Void) {
        db.collection("games").whereField("player1Id", isEqualTo: playerId)
            .whereField("isComplete", isEqualTo: false).getDocuments { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion()
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No existing games found for deletion")
                    completion()
                    return
                }
                let group = DispatchGroup()
                for document in documents {
                    group.enter()
                    self?.db.collection("games").document(document.documentID).delete { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed")
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main, execute: completion)
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

//
//  MessagesManager.swift
//  bagChal
//
//  Created by Sabir Thapa on 10/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesManager: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    var currentUserSenderId: String? {
        return Auth.auth().currentUser?.uid
    }

    
    let db = Firestore.firestore()
    
    init() {
        getMessages()
    }

    func getMessages() {
        db.collection("messages").addSnapshotListener { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            self.messages = documents.compactMap { document -> Message? in
                do {
                    if let message = try document.data(as: Message.self) {
                        var modifiedMessage = message
                        modifiedMessage.recieved = modifiedMessage.senderId != self.currentUserSenderId
                        return modifiedMessage
                    } else {
                        return nil
                    }
                } catch {
                    print("Error decoding document into Message: \(error)")
                    return nil
                }
            }
            
            self.messages.sort { $0.timestamp < $1.timestamp }
            
            // Getting the ID of the last message so we automatically scroll to it in ContentView
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
    }
    
    func sendMessage(text: String) {
        do {
            guard let senderId = self.currentUserSenderId else {
                print("Error: User not logged in")
                return
            }

            let newMessage = Message(id: "\(UUID())", senderId: senderId, text: text, recieved: false, timestamp: Date())
            try db.collection("messages").document().setData(from: newMessage)
            
        } catch {
            print("Error adding message to Firestore: \(error)")
        }
    }
    

    // Updated clear and fetch logic
    func refreshMessages() {
        clearLocalMessages() // Clear messages locally immediately
        deleteAllMessagesFromFirestore { [weak self] success in
            if success {
                self?.getMessages() // Fetch messages only after ensuring they are cleared from Firestore
            }
        }
    }

    func clearLocalMessages() {
        DispatchQueue.main.async {
            self.messages.removeAll()
        }
    }

    func deleteAllMessagesFromFirestore(completion: @escaping (Bool) -> Void) {
        db.collection("messages").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents for deletion: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            for document in documents {
                self.db.collection("messages").document(document.documentID).delete { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
}



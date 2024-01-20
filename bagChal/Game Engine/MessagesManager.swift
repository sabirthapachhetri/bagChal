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
}

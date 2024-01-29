//
//  bagChalApp.swift
//  bagChal
//
//  Created by Sabir Thapa on 30/09/2023.
//

import SwiftUI
import Firebase

@main
struct bagChalApp: App {
    @StateObject var messagesManager = MessagesManager()
    @Environment(\.scenePhase) var scenePhase

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginRegisterChoiceView()
                .environmentObject(messagesManager)
                .onChange(of: scenePhase) { newScenePhase in
                    if newScenePhase == .active {
                        messagesManager.refreshMessages() // Refresh messages when the app becomes active
                    }
                }
        }
    }
}

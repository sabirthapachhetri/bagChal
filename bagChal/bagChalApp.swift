//
//  bagChalApp.swift
//  bagChal
//
//  Created by Sabir Thapa on 30/09/2023.
//

//import SwiftUI
//import Firebase

//@main
//struct bagChalApp: App {
//
//    @AppStorage("yourName") var yourName = ""
//    @StateObject var game = GameService(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict, baghSpecialCaptureMovesDict: baghSpecialCaptureMovesDict)
//
//    init() {
//        FirebaseApp.configure()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//
//            LoginRegisterChoiceView()
//
////            if yourName.isEmpty {
////                YourNameView()
////            } else {
////                StartView(yourName: yourName)
////                    .environmentObject(game)
////            }
//
////            MessageView()
////            BaghChalBoard(userRole: .goat, playAgainstAI: true)
//        }
//    }
//}

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

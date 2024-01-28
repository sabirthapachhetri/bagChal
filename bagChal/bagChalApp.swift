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

    @AppStorage("yourName") var yourName = ""
    @StateObject var game = GameService(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict, baghSpecialCaptureMovesDict: baghSpecialCaptureMovesDict)
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            
            if yourName.isEmpty {
                YourNameView()
            } else {
                StartView(yourName: yourName)
                    .environmentObject(game)
            }
//            BaghChalBoard(userRole: nil, playAgainstAI: false)
        }
    }
}

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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BaghChalGame(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict))
        }
    }
}

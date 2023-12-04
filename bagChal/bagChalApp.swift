//
//  bagChalApp.swift
//  bagChal
//
//  Created by Sabir Thapa on 30/09/2023.
//

import SwiftUI

@main
struct bagChalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BaghChalGame(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict))
        }
    }
}

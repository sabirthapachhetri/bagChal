//
//  BaghChalGame.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import Foundation
import Combine

class BaghChalGame: ObservableObject {

    // Game state properties
    @Published var baghsTrapped: Int = 0
    @Published var goatsCaptured: Int = 0
    @Published var nextTurn: String = "G" // or "B"
    @Published var fenCount: [String: Int] = [:]
    @Published var baghPoints: Set<Point> = []
    @Published var goatPoints: Set<Point> = []
    @Published var noOfGoatMoves: Int = 0

    var initialTigerPositions: [CGPoint]
    var initialGoatPositions: [CGPoint]

    init(spacing: CGFloat) {
        // Initialize tiger positions
        initialTigerPositions = [
            CGPoint(x: 0 * spacing, y: 0 * spacing),       // Top-left
            CGPoint(x: 4 * spacing, y: 0 * spacing),       //  Top-right
            CGPoint(x: 4 * spacing, y: 4 * spacing),       // Bottom-right
            CGPoint(x: 0 * spacing, y: 4 * spacing)        // Bottom-left
        ]

        // Initialize goat positions in an overlay style
        let basePosition = CGPoint(x:160, y: 5 * spacing) // Base position for the first goat
        let overlayOffset = CGPoint(x: 0, y: 0) // Define the offset for overlaying goats

        initialGoatPositions = (0..<20).map { index in
            // Calculate the offset for each goat based on its index
            let xOffset = CGFloat(index) * overlayOffset.x
            let yOffset = CGFloat(index) * overlayOffset.y

            // Apply the offset to the base position
            return CGPoint(x: basePosition.x + xOffset, y: basePosition.y + yOffset)
        }
    }
}

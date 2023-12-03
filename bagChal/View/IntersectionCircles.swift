//
//  IntersectionCircles.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

import SwiftUI

struct IntersectionCircles: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat
    var connectedPointsDict: [Point: Set<Point>]

    var body: some View {
        ForEach(0..<rows) { row in
            ForEach(0..<columns) { column in
                Circle()
                    .fill(Color.white)
                    .frame(width: diameter, height: diameter)
                    .position(x: CGFloat(column) * spacing, y: CGFloat(row) * spacing)
                    .onTapGesture {
                        let tappedPoint = Point(x: column + 1, y: row + 1)
                        if let connectedPoints = connectedPointsDict[tappedPoint] {
                            print("Tapped Point: \(tappedPoint), Connected Points: \(connectedPoints)")
                        } else {
                            print("Tapped Point: \(tappedPoint) has no connected points.")
                        }
                    }
            }
        }
    }
}


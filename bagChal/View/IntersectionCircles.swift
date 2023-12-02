//
//  IntersectionCircles.swift
//  bagChal
//
//  Created by Sabir Thapa on 27/11/2023.
//

import SwiftUI

struct IntersectionCircles: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let diameter: CGFloat

    var body: some View {
        ForEach(0..<rows) { row in
            ForEach(0..<columns) { column in
                Circle()
                    .fill(Color.white)
                    .frame(width: diameter, height: diameter)
                    .position(x: CGFloat(column) * spacing, y: CGFloat(row) * spacing)
            }
        }
    }
}

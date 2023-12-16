//
//  Constants.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/12/2023.
//

import Foundation

import Foundation

// Define a struct to represent a point that conforms to Hashable.
struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Move {
    var from: Point
    var to: Point
    
    static func defaultMove() -> Move {
        // Define what a default move would be
        return Move(from: Point(x: 0, y: 0), to: Point(x: 0, y: 0))
    }
}

// Now, use Point as the key for the dictionary.
var connectedPointsDict: [Point: Set<Point>] = [
    Point(x: 1, y: 1): [Point(x: 1, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 2)],
    Point(x: 1, y: 2): [Point(x: 1, y: 3), Point(x: 1, y: 1), Point(x: 2, y: 2)],
    Point(x: 1, y: 3): [Point(x: 1, y: 2), Point(x: 1, y: 4), Point(x: 2, y: 3), Point(x: 2, y: 2), Point(x: 2, y: 4)],
    Point(x: 1, y: 4): [Point(x: 1, y: 5), Point(x: 1, y: 3), Point(x: 2, y: 4)],
    Point(x: 1, y: 5): [Point(x: 2, y: 5), Point(x: 2, y: 4), Point(x: 1, y: 4)],

    Point(x: 2, y: 1): [Point(x: 3, y: 1), Point(x: 1, y: 1), Point(x: 2, y: 2)],
    Point(x: 2, y: 2): [Point(x: 1, y: 2), Point(x: 3, y: 2), Point(x: 1, y: 3), Point(x: 3, y: 3), Point(x: 3, y: 1), Point(x: 2, y: 1), Point(x: 2, y: 3), Point(x: 1, y: 1)],
    Point(x: 2, y: 3): [Point(x: 2, y: 4), Point(x: 1, y: 3), Point(x: 3, y: 3), Point(x: 2, y: 2)],
    Point(x: 2, y: 4): [Point(x: 1, y: 3), Point(x: 3, y: 3), Point(x: 1, y: 4), Point(x: 1, y: 5), Point(x: 2, y: 3), Point(x: 2, y: 5), Point(x: 3, y: 4), Point(x: 3, y: 5)],
    Point(x: 2, y: 5): [Point(x: 1, y: 5), Point(x: 2, y: 4), Point(x: 3, y: 5)],

    Point(x: 3, y: 1): [Point(x: 3, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 2), Point(x: 4, y: 2), Point(x: 4, y: 1)],
    Point(x: 3, y: 2): [Point(x: 4, y: 2), Point(x: 3, y: 1), Point(x: 3, y: 3), Point(x: 2, y: 2)],
    Point(x: 3, y: 3): [Point(x: 3, y: 2), Point(x: 4, y: 4), Point(x: 2, y: 3), Point(x: 4, y: 3), Point(x: 2, y: 2), Point(x: 4, y: 2), Point(x: 3, y: 4), Point(x: 2, y: 4)],
    Point(x: 3, y: 4): [Point(x: 2, y: 4), Point(x: 4, y: 4), Point(x: 3, y: 3), Point(x: 3, y: 5)],
    Point(x: 3, y: 5): [Point(x: 4, y: 5), Point(x: 4, y: 4), Point(x: 2, y: 5), Point(x: 3, y: 4), Point(x: 2, y: 4)],

    Point(x: 4, y: 1): [Point(x: 4, y: 2), Point(x: 5, y: 1), Point(x: 3, y: 1)],
    Point(x: 4, y: 2): [Point(x: 3, y: 2), Point(x: 4, y: 1), Point(x: 3, y: 3), Point(x: 3, y: 1), Point(x: 4, y: 3), Point(x: 5, y: 1), Point(x: 5, y: 2), Point(x: 5, y: 3)],
    Point(x: 4, y: 3): [Point(x: 4, y: 2), Point(x: 4, y: 4), Point(x: 3, y: 3), Point(x: 5, y: 3)],
    Point(x: 4, y: 4): [Point(x: 5, y: 4), Point(x: 3, y: 3), Point(x: 5, y: 5), Point(x: 4, y: 5), Point(x: 4, y: 3), Point(x: 5, y: 3), Point(x: 3, y: 4), Point(x: 3, y: 5)],
    Point(x: 4, y: 5): [Point(x: 4, y: 4), Point(x: 5, y: 5), Point(x: 3, y: 5)],

    Point(x: 5, y: 1): [Point(x: 4, y: 2), Point(x: 4, y: 1), Point(x: 5, y: 2)],
    Point(x: 5, y: 2): [Point(x: 4, y: 2), Point(x: 5, y: 1), Point(x: 5, y: 3)],
    Point(x: 5, y: 3): [Point(x: 5, y: 4), Point(x: 4, y: 4), Point(x: 4, y: 3), Point(x: 4, y: 2), Point(x: 5, y: 2)],
    Point(x: 5, y: 4): [Point(x: 4, y: 4), Point(x: 5, y: 5), Point(x: 5, y: 3)],
    Point(x: 5, y: 5): [Point(x: 4, y: 5), Point(x: 5, y: 4), Point(x: 4, y: 4)]
]

var baghSpecialCaptureMovesDict: [Point: Set<Point>] = [
    Point(x: 1, y: 1): [Point(x: 1, y: 3), Point(x: 3, y: 1), Point(x: 3, y: 3)],
    Point(x: 1, y: 2): [Point(x: 3, y: 2), Point(x: 1, y: 4)],
    Point(x: 1, y: 3): [Point(x: 3, y: 3), Point(x: 3, y: 1), Point(x: 1, y: 5), Point(x: 1, y: 1), Point(x: 3, y: 5)],
    Point(x: 1, y: 4): [Point(x: 1, y: 2), Point(x: 3, y: 4)],
    Point(x: 1, y: 5): [Point(x: 1, y: 3), Point(x: 3, y: 3), Point(x: 3, y: 5)],
    Point(x: 2, y: 1): [Point(x: 4, y: 1), Point(x: 2, y: 3)],
    Point(x: 2, y: 2): [Point(x: 4, y: 2), Point(x: 4, y: 4), Point(x: 2, y: 4)],
    Point(x: 2, y: 3): [Point(x: 2, y: 5), Point(x: 2, y: 1), Point(x: 4, y: 3)],
    Point(x: 2, y: 4): [Point(x: 4, y: 2), Point(x: 4, y: 4), Point(x: 2, y: 2)],
    Point(x: 2, y: 5): [Point(x: 4, y: 5), Point(x: 2, y: 3)],
    Point(x: 3, y: 1): [Point(x: 1, y: 3), Point(x: 3, y: 3), Point(x: 5, y: 1), Point(x: 1, y: 1), Point(x: 5, y: 3)],
    Point(x: 3, y: 2): [Point(x: 1, y: 2), Point(x: 3, y: 4), Point(x: 5, y: 2)],
    Point(x: 3, y: 3): [Point(x: 1, y: 3), Point(x: 5, y: 5), Point(x: 3, y: 1), Point(x: 1, y: 5), Point(x: 5, y: 3), Point(x: 5, y: 1), Point(x: 1, y: 1), Point(x: 3, y: 5)],
    Point(x: 3, y: 4): [Point(x: 5, y: 4), Point(x: 3, y: 2), Point(x: 1, y: 4)],
    Point(x: 3, y: 5): [Point(x: 1, y: 3), Point(x: 5, y: 5), Point(x: 3, y: 3), Point(x: 1, y: 5), Point(x: 5, y: 3)],
    Point(x: 4, y: 1): [Point(x: 4, y: 3), Point(x: 2, y: 1)],
    Point(x: 4, y: 2): [Point(x: 4, y: 4), Point(x: 2, y: 4), Point(x: 2, y: 2)],
    Point(x: 4, y: 3): [Point(x: 4, y: 5), Point(x: 4, y: 1), Point(x: 2, y: 3)],
    Point(x: 4, y: 4): [Point(x: 4, y: 2), Point(x: 2, y: 4), Point(x: 2, y: 2)],
    Point(x: 4, y: 5): [Point(x: 2, y: 5), Point(x: 4, y: 3)],
    Point(x: 5, y: 1): [Point(x: 3, y: 1), Point(x: 3, y: 3), Point(x: 5, y: 3)],
    Point(x: 5, y: 2): [Point(x: 5, y: 4), Point(x: 3, y: 2)],
    Point(x: 5, y: 3): [Point(x: 5, y: 5), Point(x: 3, y: 3), Point(x: 3, y: 1), Point(x: 5, y: 1), Point(x: 3, y: 5)],
    Point(x: 5, y: 4): [Point(x: 3, y: 4), Point(x: 5, y: 2)],
    Point(x: 5, y: 5): [Point(x: 3, y: 5), Point(x: 3, y: 3), Point(x: 5, y: 3)]
]


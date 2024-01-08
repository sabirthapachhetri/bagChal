//
//  GameModel.swift
//  bagChal
//
//  Created by Sabir Thapa on 23/12/2023.
//

import SwiftUI

struct GameModel: Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var headline: String
    var gradientColors: Color
}

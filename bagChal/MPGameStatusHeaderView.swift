//
//  MPGameStatusHeaderView.swift
//  bagChal
//
//  Created by Sabir Thapa on 24/01/2024.
//

import SwiftUI

struct MPGameStatusHeaderView: View {

    @Binding var baghsTrapped: Int
    @Binding var goatsCaptured: Int
    @ObservedObject var game: GameService

    var body: some View {
        HStack {
            Image("tigerTrapped")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Baghs Trapped: \(game.baghsTrapped)")
                .font(.subheadline)
            
            Spacer()
            
            Image("goatCaptured")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Goats Captured: \(goatsCaptured)")
                .font(.subheadline)
        }
        .padding()
    }
}

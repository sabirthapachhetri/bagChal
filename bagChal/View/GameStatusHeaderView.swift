//
//  GameStatusHeaderView.swift
//  bagChal
//
//  Created by Sabir Thapa on 03/12/2023.
//

import SwiftUI

struct GameStatusHeaderView: View {

    @Binding var baghsTrapped: Int
    @Binding var goatsCaptured: Int
    @ObservedObject var game: BaghChalGame

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

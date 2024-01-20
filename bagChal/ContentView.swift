//
//  ContentView.swift
//  bagChal
//
//  Created by Sabir Thapa on 30/09/2023.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
//        LoginRegisterChoiceView()
        BaghChalBoard(userRole: .goat, playAgainstAI: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

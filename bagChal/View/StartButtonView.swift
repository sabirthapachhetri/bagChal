//
//  StartButtonView.swift
//  bagChal
//
//  Created by Sabir Thapa on 23/12/2023.
//

import SwiftUI

struct StartButtonView: View {
  // MARK: - PROPERTIES
  
  @AppStorage("isOnboarding") var isOnboarding: Bool?
    var action: () -> Void

    // MARK: - BODY
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("START")
                Image(systemName: "arrow.right.circle").imageScale(.large)
            }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(
        Capsule().strokeBorder(Color.black, lineWidth: 1.25)
      )
    } //: BUTTON
    .accentColor(Color.black)
  }
}

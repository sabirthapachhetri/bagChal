//
//  CardView.swift
//  bagChal
//
//  Created by Sabir Thapa on 17/12/2023.
//

import SwiftUI

struct CardView: View {
    
    // MARK: - PROPERTIES
    @State private var isAnimating: Bool = false
    var gameData: GameModel
    var onButtonPress: () -> Void  // Closure for button action

    // MARK: - BODY
    var body: some View {

        ZStack{
            VStack(spacing: 20) {
                
                Image(gameData.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
                
                Text(gameData.title)
                    .foregroundColor(Color.black)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 2, x: 2, y: 2)
                
                Text(gameData.headline)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 480)
                    .padding(.bottom)
                
                StartButtonView(action: onButtonPress)
            }
            
        }
        .onAppear{
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

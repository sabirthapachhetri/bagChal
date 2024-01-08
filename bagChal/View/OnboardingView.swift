//
//  OnboardingView.swift
//  bagChal
//
//  Created by Sabir Thapa on 16/12/2023.
//

import SwiftUI

enum NavigationDestination {
    case baghChalBoard
    case otherDestination1 // Define other destinations as needed
    case otherDestination2
}

struct OnboardingView: View {
    
    var gameDatas: [GameModel] = gameData
    @State private var selectedIndex = 0
    @State private var navigationDestination: NavigationDestination?
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(gameData.indices, id: \.self) { index in
                    CardView(gameData: gameData[index]) {
                        navigationDestination = index == 0 ? .baghChalBoard : .otherDestination1
                    }
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            
            // Navigation Links for different destinations
            NavigationLink(destination: BaghChalBoard(), isActive: Binding(
                get: { navigationDestination == .baghChalBoard },
                set: { if !$0 { navigationDestination = nil } }
            )) { EmptyView() }

            VStack {
                Spacer() // This pushes the page indicator to the bottom
                PageIndicator(index: $selectedIndex, maxIndex: gameData.count - 1)
                    .padding()
                    .padding(.bottom, -30)// Add padding if necessary
            }
        }
    }
}

struct PageIndicator: View {
    @Binding var index: Int
    let maxIndex: Int

    var body: some View {
        HStack {
            ForEach(0...maxIndex, id: \.self) { i in
                Circle()
                    .fill(i == index ? Color.primary : Color.secondary)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(gameDatas: gameData)
    }
}

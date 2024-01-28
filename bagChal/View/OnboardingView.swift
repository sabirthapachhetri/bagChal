//
//  OnboardingView.swift
//  bagChal
//
//  Created by Sabir Thapa on 16/12/2023.
//

import SwiftUI

enum NavigationDestination {
    case baghChalBoard
    case gameLobbyView
    case messageView
    case peerView
}

enum PlayerRole {
    case goat, tiger
}

struct OnboardingView: View {
    var gameDatas: [GameModel] = gameData
    @State private var selectedIndex = 0
    @State private var navigationDestination: NavigationDestination?
    @State private var userRole: PlayerRole? = nil
    @State private var playAgainstAI: Bool = false
    @State private var showingRoleChoiceAlert = false
    
    @State private var startGame = true
    @StateObject var mpConnectionManager = MPConnectionManager(yourName: "Eric Cartman")

    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(gameData.indices, id: \.self) { index in
                    CardView(gameData: gameData[index]) {
                        if index == 2 {
                            showingRoleChoiceAlert = true
                        } else if index == 1 {
                            navigationDestination = .peerView
                        } else {
                            navigationDestination = index == 0 ? .baghChalBoard : .peerView
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .navigationBarTitle("", displayMode: .inline) // Clear the title and set it to inline mode
            .navigationBarHidden(true) // Hide the navigation bar

            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            
            NavigationLink(destination: BaghChalBoard(userRole: nil, playAgainstAI: false), tag: .baghChalBoard, selection: $navigationDestination) {
                EmptyView()
            }
            
            NavigationLink(destination: BaghChalBoard(userRole: userRole, playAgainstAI: playAgainstAI), tag: .baghChalBoard, selection: $navigationDestination) {
                EmptyView()
            }
            
            NavigationLink(destination: MPPeersView(startGame: $startGame).environmentObject(mpConnectionManager), tag: .peerView, selection: $navigationDestination) {
                EmptyView()
            }

            VStack {
                Spacer()
                PageIndicator(index: $selectedIndex, maxIndex: gameData.count - 1)
                    .padding()
                    .padding(.bottom, -30)
            }
        }
        .alert("Choose Your Role", isPresented: $showingRoleChoiceAlert) {
            Button("Goat") {
                userRole = .goat
                playAgainstAI = true // Set to true since the user is playing against AI
                navigationDestination = .baghChalBoard
            }
            Button("Tiger") {
                userRole = .tiger
                playAgainstAI = true // Set to true since the user is playing against AI
                navigationDestination = .baghChalBoard
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

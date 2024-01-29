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
    @StateObject private var aiGame = BaghChalGame(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict, baghSpecialCaptureMovesDict: baghSpecialCaptureMovesDict)
    
    @AppStorage("yourName") var yourName = ""
    @StateObject var game = GameService(spacing: 80, rows: 5, columns: 5, diameter: 40, connectedPointsDict: connectedPointsDict, baghSpecialCaptureMovesDict: baghSpecialCaptureMovesDict)

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
            
            NavigationLink(destination: AIBoardView(userRole: userRole, playAgainstAI: playAgainstAI, aiGame: aiGame), tag: .gameLobbyView, selection: $navigationDestination) { 
                EmptyView()
            }
            
            Group {
                if navigationDestination == .peerView && yourName.isEmpty {
                    NavigationLink(destination: YourNameView(), isActive: .constant(true)) {
                        EmptyView()
                    }
                } else if navigationDestination == .peerView {
                    NavigationLink(destination: StartView(yourName: yourName).environmentObject(game), isActive: .constant(true)) {
                        EmptyView()
                    }
                }
            }
            
            VStack {
                Spacer()
                PageIndicator(index: $selectedIndex, maxIndex: gameData.count - 1)
                    .padding()
                    .padding(.bottom, -30)
            }
        }
        .onAppear {
            aiGame.resetGame()
            navigationDestination = nil
        }
        .alert("Choose Your Role", isPresented: $showingRoleChoiceAlert) {
            Button("Goat") {
                userRole = .goat
                playAgainstAI = true
                aiGame.nextTurn = "G"
                navigationDestination = .gameLobbyView
            }
            Button("Tiger") {
                userRole = .tiger
                playAgainstAI = true
                aiGame.nextTurn = "B"
                navigationDestination = .gameLobbyView
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

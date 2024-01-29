//
//  MessageView.swift
//  bagChal
//
//  Created by Sabir Thapa on 10/01/2024.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var messagesManager: MessagesManager

    var body: some View {
        VStack {
            VStack {                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight]) 
                    .onChange(of: messagesManager.lastMessageId) { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color.white)
            
            MessageField()
                .environmentObject(messagesManager)
        }
    }
}

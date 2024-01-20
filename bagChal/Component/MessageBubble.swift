//
//  MessageBubble.swift
//  bagChal
//
//  Created by Sabir Thapa on 10/01/2024.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: message.recieved ? .leading : .trailing) {
            HStack {
                Text(message.text)
                    .padding()
                    .background(message.recieved ? Color.gray : Color.orange)
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: message.recieved ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.recieved ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.recieved ? .leading : .trailing)
        .padding(message.recieved ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}


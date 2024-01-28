//
//  YourNameView.swift
//  bagChal
//
//  Created by Sabir Thapa on 25/01/2024.
//

import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    var body: some View {
        VStack {
            Text("This is the name that will be associated with this device.")
            TextField("Your Name", text: $userName)
                .textFieldStyle(.roundedBorder)
            Button("Set") {
                yourName = userName
            }
            .buttonStyle(.borderedProminent)
            .disabled(userName.isEmpty)
            Image("tigerGoat")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Spacer()
        }
        .padding()
        .navigationTitle("BaghChal")
        .inNavigationStack()
    }
}

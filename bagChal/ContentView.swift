//
//  ContentView.swift
//  bagChal
//
//  Created by Sabir Thapa on 30/09/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var loginRegisterSelected = "Login"
    var loginRegisterOptions = ["Login", "Register"]

    var body: some View {
        ZStack {
            Color(red: 48/255, green: 68/255, blue: 158/255)
                .ignoresSafeArea()
            
            VStack{
                Text("Hello, There")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.bottom, 1)
                
                Text("Welcome Back")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Picker("", selection: $loginRegisterSelected) {
                    ForEach(loginRegisterOptions, id: \.self) {
                        // do sth
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

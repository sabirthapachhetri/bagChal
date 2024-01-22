//
//  LoginView.swift
//  bagChal
//
//  Created by Sabir Thapa on 01/10/2023.
//

import SwiftUI

struct LoginRegisterChoiceView: View {
    @State private var showingLogin = false
    @State private var showingRegister = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("Bagchal Adventure: \nExplore the World of Strategy")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color.black)
                            .padding()
                        Spacer()
                    }

                    Spacer()

                    Image("tigerGoat")
                        .resizable()
                        .scaledToFit() // Adapt image size to the parent view
                        .padding() // Adaptive padding

                    Spacer()

                    // Use NavigationLink for login
                    NavigationLink(destination: LoginView(), isActive: $showingLogin) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding() // Adaptive padding
                            .frame(minWidth: 0, maxWidth: .infinity) // Flexible width
                            .background(Color.orange)
                            .cornerRadius(10)
                    }

                    // Create account button
                    Button(action: {
                        self.showingRegister = true
                    }) {
                        Text("Create account")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding() // Adaptive padding
                            .frame(minWidth: 0, maxWidth: .infinity) // Flexible width
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .sheet(isPresented: $showingRegister) {
                        RegisterView()
                    }

                    Spacer()
                }
                .padding() // Padding for the entire VStack
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 249/255, green: 244/255, blue: 236/255, opacity: 1))
        }
        .accentColor(Color.orange)
    }
}

struct LoginRegisterChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterChoiceView()
    }
}
 

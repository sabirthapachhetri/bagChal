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
        NavigationView { // Add this
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
                            .padding(.leading)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Image("tigerGoat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 450, height: 450)
                    
                    Spacer()
                    
                    // Use NavigationLink for login
                    NavigationLink(destination: LoginView(), isActive: $showingLogin) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 350, height: 44)
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
                            .frame(width: 350, height: 44)
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
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 249/255, green: 244/255, blue: 236/255, opacity: 1))
        } // End NavigationView
    }
}

struct LoginRegisterChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterChoiceView()
    }
}

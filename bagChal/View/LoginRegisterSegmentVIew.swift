//
//  LoginRegisterSegmentVIew.swift
//  bagChal
//
//  Created by Sabir Thapa on 01/10/2023.
//

import SwiftUI

struct LoginRegisterSegmentVIew: View {
    
    @State private var loginRegisterSelected = "Login"
    var loginRegisterOptions = ["Login", "Register"]

    var body: some View {
        ZStack {
            Color(red: 48/255, green: 68/255, blue: 158/255)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                VStack{
                    Text("Hello, There")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 25)
                        .padding(.bottom, 1)
                    
                    Text("Welcome Back")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 25)

                    Picker("", selection: $loginRegisterSelected) {
                        ForEach(loginRegisterOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .cornerRadius(90)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)
                    .frame(height: 50)
                }
                .frame(width: 350)
                .background(Color(red: 65/255, green: 87/255, blue: 191/255))
                .cornerRadius(24)
                
                if loginRegisterSelected == "Login" {
                    LoginView()
                        .background(Color.white)
                        .cornerRadius(24)
                }
                
                if loginRegisterSelected == "Register" {
                    RegisterView()
                        .background(Color.white)
                        .cornerRadius(24)
                }
                
                Spacer()
            }
            .padding(.top)
            .padding(.bottom, -80)
        }
    }
}

struct LoginRegisterSegmentVIew_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterSegmentVIew()
    }
}



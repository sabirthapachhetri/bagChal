//
//  LoginView.swift
//  bagChal
//
//  Created by Sabir Thapa on 01/10/2023.
//

import SwiftUI

struct LoginView: View {
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Login to Your Account")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 15)

            Text("Make sure that you already have an account.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, -15)

            Text("Email Address")
                .font(.headline)
                .padding(.top)
            TextField("Enter your email", text: $emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
            
            Text("Password")
                .font(.headline)
            HStack {
                if isPasswordVisible {
                    TextField("Enter your password", text: $password)
                        .padding(5)
                } else {
                    SecureField("Enter your password", text: $password)
                        .padding(10)
                }

                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))

            Button(action: {
                // Handle login action
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 48/255, green: 68/255, blue: 158/255))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 100)
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewLayout(.fixed(width: 450, height: 1200))
    }
}

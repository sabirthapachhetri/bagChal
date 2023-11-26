//
//  RegisterView.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/10/2023.
//

//
//  LoginView.swift
//  bagChal
//
//  Created by Sabir Thapa on 01/10/2023.
//

import SwiftUI

struct RegisterView: View {
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var termsAccepted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Create Your Account")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 15)

            Text("Make sure to keep your account secure.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, -15)
            
            Text("Email Address")
                .font(.headline)
                .padding(.top)
            TextField("Enter your email", text: $emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
            
            Text("Password")
                .font(.headline)
            HStack {
                if isPasswordVisible {
                    TextField("Enter your password", text: $password)
                        .padding(10)
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

            HStack {
                Toggle("", isOn: $termsAccepted)
                    .fixedSize()
                Text("I agree with the terms and conditions.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Button(action: {
                // Handle login action
            }) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 48/255, green: 68/255, blue: 158/255))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 90)
            .padding(.bottom)
            
//            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .previewLayout(.fixed(width: 450, height: 1200))
    }
}


//
//  LoginView.swift
//  bagChal
//
//  Created by Sabir Thapa on 01/10/2023.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSignedIn = false

    var body: some View {
        NavigationView {
            VStack {
                Image("loginPage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 450, height: 450)
                
                HStack {
                    Text("Sign in to your account")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.top)
                .padding(.leading, 15)
                .padding(.bottom, 45)

                CustomTextField(imageName: "envelope", placeholderText: "Email ID", isSecureField: false, text: $email)
                    .padding(.bottom, 25)

                CustomTextField(imageName: "lock", placeholderText: "Password", isSecureField: true, text: $password)
                    .padding(.bottom, 35)

                Button("Sign In") {
                    signInUser()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(10)

                NavigationLink(destination: HomeView(), isActive: $isSignedIn) {
                    EmptyView()
                }

                Spacer()
            }
            .padding()
            .background(Color(red: 254/255, green: 254/255, blue: 254/255).ignoresSafeArea(edges: .all))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
//                        if isSignedIn {
//                            // Optionally reset the navigation stack
//                            self.presentationMode.wrappedValue.dismiss()
//                        }
                    }
                )
            }
        }
    }

    private func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.alertTitle = "Sign In Failed"
                self.alertMessage = e.localizedDescription
                self.showAlert = true
                self.isSignedIn = false
            } else {
                self.alertTitle = "Sign In Successful"
                self.alertMessage = "Welcome back!"
                self.showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                     self.isSignedIn = true
                 }
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct CustomTextField: View {
    let imageName: String
    let placeholderText: String
    let isSecureField: Bool
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 10)
                if isSecureField {
                    SecureField(placeholderText, text: $text)
                } else {
                    TextField(placeholderText, text: $text)
                }
            }
            .padding(.horizontal)

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray)
                .padding(.leading, 56)
                .padding(.trailing, 5)
        }
    }
}

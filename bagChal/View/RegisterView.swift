//
//  RegisterView.swift
//  bagChal
//
//  Created by Sabir Thapa on 02/10/2023.
//

import SwiftUI
import Firebase

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack {
                Image("registerPage")
                    .resizable()
                    .scaledToFit() // Adapt image size to the parent view
                    .padding() // Adaptive padding

                HStack {
                    Text("Create your account")
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
                    .padding(.bottom, 25)

                CustomTextField(imageName: "lock", placeholderText: "Confirm your password", isSecureField: true, text: $confirmPassword)
                    .padding(.bottom, 35)

                Button("Register", action: {
                    registerUser()
                })
                .foregroundColor(.white)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity) // Flexible width
                .background(Color.orange)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .background(Color(red: 241/255, green: 241/255, blue: 241/255).ignoresSafeArea(edges: .all))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Registration Successful" {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .navigationBarItems(trailing: Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .background(Color(red: 241/255, green: 241/255, blue: 241/255).ignoresSafeArea(edges: .all))
    }

    private func registerUser() {
        if password == confirmPassword {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.alertTitle = "Registration Failed"
                    self.alertMessage = e.localizedDescription
                    self.showAlert = true
                } else {
                    self.alertTitle = "Registration Successful"
                    self.alertMessage = "Use this to sign in."
                    self.showAlert = true
                }
            }
        } else {
            self.alertTitle = "Password Mismatch"
            self.alertMessage = "Your passwords do not match. Please try again."
            self.showAlert = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

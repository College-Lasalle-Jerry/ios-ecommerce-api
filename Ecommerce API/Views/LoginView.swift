//
//  LoginView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-15.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool // Binding to isLoggedIn from ContentView
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .onChange(of: email) { oldValue, newValue in
                    validateEmail()
                }
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Login") {
                Task {
                    do {
                        if email.isEmpty || password.isEmpty {
                            errorMessage = "Email or Password cannot be empty."
                            return
                        }
                        let response = try await NetworkManager.shared.login(email: email, password: password)
                        if response.status == 200 {
                            isLoggedIn = true // Navigate to ProductsView
                        } else {
                            errorMessage = response.msg
                        }
                    } catch {
                        errorMessage = "Login failed. Please try again."
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Login")
    }
    func validateEmail() {
        if email.isEmpty {
            errorMessage = "Email cannot be empty."
        } else if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address."
        } else {
            errorMessage = ""  // Clear error if email is valid
        }
    }
    
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}

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
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Login") {
                    Task {
                        do {
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

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("Login")
        }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}

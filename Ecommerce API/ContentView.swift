//
//  ContentView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "userToken") != nil
    
    var body: some View {
        NavigationStack{
            if isLoggedIn {
                //
                HomeView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

#Preview {
    ContentView()
}

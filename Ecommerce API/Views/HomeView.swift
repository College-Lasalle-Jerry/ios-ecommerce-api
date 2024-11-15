//
//  HomeView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-15.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ProductsView()
                .tabItem{
                    Image(systemName: "bag.badge.plus.fill")
                }
            
            AddressView()
                .tabItem{
                    Image(systemName: "map.fill")
                }
        }
    }
}

#Preview {
    HomeView()
}

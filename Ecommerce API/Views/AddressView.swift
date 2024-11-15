//
//  AddressView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-15.
//

import SwiftUI

struct AddressView: View {
    @State private var isLoading = true
    @State private var addresses: [Address] = []
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("My Addresses")
                    .font(.title)
                    .fontWeight(.bold)
                if isLoading {
                    ProgressView("Loading addresses...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if addresses.isEmpty {
                    Text("No addresses available.")
                        .padding()
                } else {
                    List(addresses, id: \._id) { address in
                        AddressRowView(address: address)
                    }
                    .listStyle(PlainListStyle())
                }
            }
//            .navigationTitle("Addresses")
            .task {
                await loadAddresses()
            }
        }
    }
    // Function to load addresses from the network
    private func loadAddresses() async {
        do {
            let response = try await NetworkManager.shared.fetchAddresses()
            if response.status == 200 {
                addresses = response.data
            } else {
                errorMessage = response.msg
            }
        } catch {
            errorMessage = "Failed to load addresses: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
}

struct AddressRowView: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(address.street)
                .font(.headline)
            Text("\(address.city), \(address.state) \(address.zip)")
                .font(.subheadline)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AddressView()
}

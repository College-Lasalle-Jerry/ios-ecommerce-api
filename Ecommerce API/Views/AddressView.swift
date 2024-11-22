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
    
    @State private var showAddAddressForm = false
    @State private var showEditAddressForm = false
    @State private var editingAddress: Address? = nil
    @State private var newStreet = ""
    @State private var newCity = ""
    @State private var newState = ""
    @State private var newZip = ""
    
    var body: some View {
        VStack {
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
                List{
                    ForEach(addresses, id: \._id) {
                        address in
                        AddressRowView(address: address)
                            .onTapGesture {
                                editingAddress = address
                                newStreet = address.street
                                newCity = address.city
                                newState = address.state
                                newZip = address.zip
                                showEditAddressForm.toggle()
                            }
                    }.onDelete(perform: deleteAddress)
                    
                }
                .listStyle(PlainListStyle())
            }
            
            Button(action: {
                showAddAddressForm.toggle()
            }) {
                Text("Add New Address")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }.padding()
        }
        .sheet(isPresented: $showAddAddressForm) {
            VStack{
                Text("Add Address")
                TextField("Street", text: $newStreet)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                TextField("City", text: $newCity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                TextField("State", text: $newState)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                TextField("Zip Code", text: $newZip)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                Button("Save Address"){
                    Task {
                        await addAddress()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(newStreet.isEmpty || newCity.isEmpty || newState.isEmpty || newZip.isEmpty)
            }
            .padding()
        }
        .sheet(isPresented: $showEditAddressForm) {
            VStack {
                Text("Edit Address")
                addressForm()
                Button("Update Address") {
                    Task {
                        if let editingAddress = editingAddress {
                            await editAddress(addressId: editingAddress._id)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(newStreet.isEmpty || newCity.isEmpty || newState.isEmpty || newZip.isEmpty)
            }
            .padding()
        }
        .onAppear {
            Task {
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
    
    
    // Function to add a new address
    private func addAddress() async {
        do {
            if newStreet.isEmpty || newCity.isEmpty || newState.isEmpty || newZip.isEmpty {
                errorMessage = "Please fill out all fields"
                return
            }
            let response = try await NetworkManager.shared.addAddress(
                street: newStreet,
                city: newCity,
                state: newState,
                zip: newZip
            )
            if response.status == 200 {
                addresses.append(response.data)
                showAddAddressForm = false
                newStreet = ""
                newCity = ""
                newState = ""
                newZip = ""
            } else {
                errorMessage = response.msg
            }
        } catch {
            errorMessage = "Failed to add address"
        }
    }
    
    func deleteAddress(at offsets: IndexSet) {
        offsets.forEach { index in
            let addressId = addresses[index]._id
            Task {
                do {
                    let response = try await NetworkManager.shared.deleteAddress(addressId: addressId)
                    if response.status == 200 {
                        addresses.remove(atOffsets: offsets)
                    }else {
                        errorMessage = response.msg
                    }
                    
                } catch {
                    errorMessage = "Failed to delete address"
                }
            }
        }
    }
    
    
    
    private func addressForm() -> some View {
        VStack {
            TextField("Street", text: $newStreet)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            TextField("City", text: $newCity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            TextField("State", text: $newState)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            TextField("Zip Code", text: $newZip)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    private func editAddress(addressId: String) async {
        do {
            if newStreet.isEmpty || newCity.isEmpty || newState.isEmpty || newZip.isEmpty {
                errorMessage = "Please fill out all fields"
                return
            }

            let response = try await NetworkManager.shared.updateAddress(
                addressId: addressId,
                street: newStreet,
                city: newCity,
                state: newState,
                zip: newZip
            )
            if response.status == 200 {
                if let index = addresses.firstIndex(where: { $0._id == addressId }) {
                    addresses[index] = response.data
                }
                showEditAddressForm = false
                clearForm()
            } else {
                errorMessage = response.msg
            }
        } catch {
            errorMessage = "Failed to update address"
        }
    }
    
    private func clearForm() {
        newStreet = ""
        newCity = ""
        newState = ""
        newZip = ""
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

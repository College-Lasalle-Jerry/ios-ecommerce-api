//
//  ProductDetailView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-21.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @State private var isAddedToCart = false
    @State private var errorMessage: String?
    @State private var quantity: Int = 1 // Default quantity
    
    var body: some View {
        ScrollView{
            VStack(alignment:.leading, spacing: 20) {
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300) // Large image display
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    Color.gray
                        .frame(height: 300)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(product.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                    
                    Text(product.description) // Assuming a description field exists
                        .font(.title3)
                        .layoutPriority(1)
                        .padding(.horizontal)
                    
                    Text("\(product.stock) left, Hurry!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                                    
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...product.stock)
                    .padding()
                
                
                Button(action: {
                    Task {
                        await addToCart()
                    }
                }) {
                    Text(isAddedToCart ? "Added to Cart" : "Add to Cart")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isAddedToCart ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                Spacer()
            }        }
        .navigationTitle(product.name) // Set navigation bar title
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addToCart() async {
        do {
            let response = try await NetworkManager.shared.addToCart(productId: product._id, quantity: quantity)
            
            if response.status == 200 {
                isAddedToCart = true
            } else {
                errorMessage = response.msg
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    let product = Product.init(_id: "", name: "Product Name", description: "Product Description", price: 100.0, stock: 10, imageUrl: "")
    ProductDetailView(product: product)
}

//
//  CartView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-21.
//

import SwiftUI

struct CartView: View {
    @State private var cart: Cart?
    @State private var products: [Product] = []
    @State private var errorMessage: String = ""
    @State private var checkoutMessage: String = ""
    
    // Slider state
    @State private var sliderOffset: CGFloat = 0
    @State private var isSliding: Bool = false
    @State private var isCheckoutSuccessful: Bool = false
    // Dismiss environment to go back to HomeView
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            if let cart = cart {
                if !isCheckoutSuccessful {
                    List(cart.products, id: \._id) { cartProduct in
                        if let product = products.first(where: { $0._id == cartProduct.product }) {
                            CartRowView(quantity: cartProduct.quantity, product: product)
                            
                        } else {
                            Text("Product details not found")
                        }
                    }
                    
                }else {
                    Text("Checkout Successful!, Your cart is now empty, go and empty your wallets.")
                        .foregroundStyle(.green)
                }
                Spacer()
                sliderButton
            } else {
                Text(errorMessage.isEmpty ? "Loading..." : errorMessage)
            }
            
            if !checkoutMessage.isEmpty {
                Text(checkoutMessage)
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            loadCartData()
        }
    }
    
    // Custom slider button view
    //    var sliderButton: some View {
    //        ZStack {
    //            RoundedRectangle(cornerRadius: 25)
    //                .fill(Color.gray.opacity(0.3))
    //                .frame(height: 60)
    //                .overlay(Text("Slide to Checkout").foregroundColor(.black))
    //
    //            RoundedRectangle(cornerRadius: 25)
    //                .fill(Color.blue)
    //                .frame(width: 60, height: 60)
    //                .offset(x: sliderOffset - 150)
    //                .gesture(
    //                    DragGesture()
    //                        .onChanged { value in
    //                            sliderOffset = max(0, min(value.translation.width, 240)) // Limit slider range
    //                        }
    //                        .onEnded { value in
    //                            if sliderOffset > 200 { // Threshold to complete slide
    //                                checkoutCart() // Trigger checkout
    //                            }
    //                            // Reset slider
    //                            withAnimation {
    //                                sliderOffset = 0
    //                            }
    //                        }
    //                )
    //        }
    //        .padding()
    //    }
    
    
    var sliderButton: some View {
        ZStack(alignment: .leading) {
            // Background Track
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 60)
            
            // Dynamic Fill
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.blue)
                .frame(width: sliderOffset + 60, height: 60)  // Adjust fill width based on sliderOffset
            
            // Text (always centered)
            Text("Slide to Checkout")
                .foregroundColor(.black.opacity(0.4))
                .frame(maxWidth: .infinity)
            
            // Sliding Handle
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .offset(x: sliderOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Limit slider range
                            sliderOffset = max(0, min(value.translation.width, 300))
                        }
                        .onEnded { value in
                            // Trigger checkout when past threshold
                            if sliderOffset > 200 {
                                checkoutCart()
                            }
                            // Reset slider after action
                            withAnimation {
                                sliderOffset = 0
                            }
                        }
                )
        }
        .padding()
        .cornerRadius(25)
    }
    
    
    func loadCartData() {
        Task {
            do {
                let cartResponse = try await NetworkManager.shared.cartInfo()
                if cartResponse.status == 200 {
                    self.cart = cartResponse.data
                    // Fetch product details
                    let productResponse = try await NetworkManager.shared.fetchProducts()
                    if productResponse.status == 200 {
                        self.products = productResponse.data
                    }
                } else {
                    self.errorMessage = cartResponse.msg
                }
            } catch {
                self.errorMessage = "Error loading cart: \(error.localizedDescription)"
            }
        }
    }
    
    func checkoutCart() {
        Task {
            do {
                let response = try await NetworkManager.shared.checkoutCart()
                if response.status == 200 {
                    self.checkoutMessage = "Checkout successful!"
                    isCheckoutSuccessful = true
                    cart = nil // clear cart after successfull checkout.
                    products = [] // clear the product list.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()  // Go back to HomeView after 2 seconds
                    }
                } else {
                    self.checkoutMessage = "Checkout failed: \(response.msg)"
                }
            } catch {
                self.checkoutMessage = "Error during checkout: \(error.localizedDescription)"
            }
        }
    }
}


struct CartRowView: View {
    let quantity: Int
    let product: Product
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image.resizable().scaledToFit().frame(width: 50, height: 50)
                    .cornerRadius(15)
            } placeholder: {
                ProgressView().frame(width: 25, height: 25)
            }
            
            Text(product.name)
            Spacer()
            Text("Quantity: \(quantity)")
        }
    }
}

#Preview {
    CartView()
}

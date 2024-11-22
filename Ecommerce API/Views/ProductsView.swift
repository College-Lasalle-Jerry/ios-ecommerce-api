//
//  ProductsView.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-15.
//

import SwiftUI

// Products View
struct ProductsView: View {
    @State private var isLoading = true // Indicates whether products are being loaded
    @State private var products: [Product] = [] // Holds the list of products
    @State private var errorMessage: String? // Optional error message
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())] // 3 columns in the grid
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading products...") // Loading indicator with a message
                    .padding()
            }
            else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)") // Display error message if an error occurs
                    .foregroundColor(.red)
                    .padding()
            }
            else if products.isEmpty {
                Text("No products available.") // Message if no products are available
                    .padding()
            } else {
                //                    List(products, id: \._id) { product in
                //                        ProductRowView(product: product)
                //                    }
                //                    .listStyle(PlainListStyle())
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(products, id: \._id) { product in
                            ProductRowView(product: product) // Reuse the product row view for each product
                                .frame(maxWidth: .infinity) // Make each grid item take full width
                                .background(Color.white) // Optional background color for the grid item
                                .cornerRadius(10) // Optional corner radius for the grid item
                                .shadow(radius: 5) // Optional shadow for visual effect
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .onAppear{
            Task {
                await loadProducts()
            }
        }
    }
    
    private func loadProducts() async {
        do {
            let response = try await NetworkManager.shared.fetchProducts()
            
            // Checking if the response status is 200 and then loading data
            if response.status == 200 {
                products = response.data
            } else {
                errorMessage = response.msg // Using the error message from the response
            }
        } catch {
            errorMessage = "Failed to load products. Please try again."
        }
        isLoading = false
    }
    
}

// A simple view to represent each product in the list
struct ProductRowView: View {
    let product: Product
    
    
    var body: some View {
        NavigationLink {
            ProductDetailView(product: product)
        } label: {
            VStack {
                // Display product image
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80) // Adjust size as needed
                } placeholder: {
                    Color.gray // Placeholder while loading
                        .frame(width: 80, height: 80)
                }
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    
                    Text("$\(product.price, specifier: "%.2f")") // Format price to 2 decimal places
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)

        }

    }
}

#Preview {
    ProductsView()
}

//
//  NetworkManager.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


// Define the protocol
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Make URLSession conform to the protocol
extension URLSession: URLSessionProtocol {}

// Define the mock class for testing
class MockURLSession: URLSessionProtocol {
    var nextData: Data?
    var nextError: Error?
    var lastURL: URL?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastURL = request.url
        if let error = nextError {
            throw error
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (nextData ?? Data(), response)
    }
}


public class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.jerryjoy.me/api"
    private var token: String?
    private var session: URLSessionProtocol
    
//    private init() {}
    
    init(session: URLSessionProtocol = URLSession.shared) { // Use URLSessionProtocol here
        self.session = session
    }
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    private func request<T: Codable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)")
        else {
            print("\(baseURL)\(endpoint)")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // Authentication
    func register(name: String, email: String, password: String) async throws -> User {
        let registerData = ["name": name, "email": email, "password": password]
        let data = try JSONEncoder().encode(registerData)
        return try await request(endpoint: "/auth/register", method: "POST", body: data)
    }
    
    func login(email: String, password: String) async throws -> String {
        let loginData = ["email": email, "password": password]
        let data = try JSONEncoder().encode(loginData)
        struct LoginResponse: Codable { let data: String }
        let result: LoginResponse = try await request(endpoint: "/auth/login", method: "POST", body: data)
        setToken(result.data)
        return result.data
    }
    
    func fetchUserProfile() async throws -> User {
        return try await request(endpoint: "/auth/profile")
    }
    
    // Product APIs
    func fetchProducts() async throws -> [Product] {
        struct productResponse: Codable { let data: [Product]}
        let result: productResponse = try await request(endpoint: "/products")
        return result.data
    }
    
    // Cart APIs
    func addToCart(productId: String, quantity: Int) async throws -> Cart {
        let cartData = CartRequest(product: productId, quantity: quantity)
        let data = try JSONEncoder().encode(cartData)
        return try await request(endpoint: "/cart/add", method: "POST", body: data)
    }
    
    func checkoutCart() async throws -> Order {
        return try await request(endpoint: "/cart/checkout", method: "POST")
    }
    
    // Address APIs
    func addAddress(street: String, city: String, state: String, zip: String) async throws -> Address {
        let addressData = ["street": street, "city": city, "state": state, "zip": zip]
        let data = try JSONEncoder().encode(addressData)
        return try await request(endpoint: "/addresses", method: "POST", body: data)
    }
    
    func fetchAddresses() async throws -> [Address] {
        return try await request(endpoint: "/addresses")
    }
    
    func updateAddress(addressId: String, street: String, city: String, state: String, zip: String) async throws -> Address {
        let addressData = AddressRequest(street: street, city: city, state: state, zip: zip)
        let data = try JSONEncoder().encode(addressData)
        return try await request(endpoint: "/addresses/\(addressId)", method: "PUT", body: data)
    }
    
    func deleteAddress(addressId: String) async throws {
        _ = try await request(endpoint: "/addresses/\(addressId)", method: "DELETE") as Address?
    }
    
    // Orders
    func fetchUserOrders() async throws -> [Order] {
        return try await request(endpoint: "/order")
    }
}
